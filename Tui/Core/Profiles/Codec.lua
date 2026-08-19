local TUI = TUI

TUI.ProfileCodec = TUI.ProfileCodec or {}
local C = TUI.ProfileCodec

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b64lookup = {}
for i = 1, #b64chars do b64lookup[b64chars:sub(i, i)] = i - 1 end

local function b64encode(data)
    local out = {}
    local n = #data
    local i = 1
    while i <= n do
        local a = data:byte(i) or 0
        local b = data:byte(i + 1) or 0
        local c = data:byte(i + 2) or 0
        local triple = a * 65536 + b * 256 + c
        local c1 = math.floor(triple / 262144) % 64
        local c2 = math.floor(triple / 4096) % 64
        local c3 = math.floor(triple / 64) % 64
        local c4 = triple % 64
        out[#out + 1] = b64chars:sub(c1 + 1, c1 + 1)
        out[#out + 1] = b64chars:sub(c2 + 1, c2 + 1)
        out[#out + 1] = (i + 1 <= n) and b64chars:sub(c3 + 1, c3 + 1) or "="
        out[#out + 1] = (i + 2 <= n) and b64chars:sub(c4 + 1, c4 + 1) or "="
        i = i + 3
    end
    return table.concat(out)
end

local function b64decode(data)
    data = (data or ""):gsub("%s+", "")
    if (#data % 4) ~= 0 then return nil, "base64-length" end
    local out = {}
    for i = 1, #data, 4 do
        local c1, c2, c3, c4 = data:sub(i, i), data:sub(i + 1, i + 1), data:sub(i + 2, i + 2), data:sub(i + 3, i + 3)
        local a, b = b64lookup[c1], b64lookup[c2]
        local c = c3 == "=" and 0 or b64lookup[c3]
        local d = c4 == "=" and 0 or b64lookup[c4]
        if a == nil or b == nil or c == nil or d == nil then return nil, "base64-char" end
        local triple = a * 262144 + b * 4096 + c * 64 + d
        out[#out + 1] = string.char(math.floor(triple / 65536) % 256)
        if c3 ~= "=" then out[#out + 1] = string.char(math.floor(triple / 256) % 256) end
        if c4 ~= "=" then out[#out + 1] = string.char(triple % 256) end
    end
    return table.concat(out)
end

local function sortedKeys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b)
        local ta, tb = type(a), type(b)
        if ta ~= tb then return ta < tb end
        return tostring(a) < tostring(b)
    end)
    return keys
end

local function serialize(v, seen)
    local tv = type(v)
    if tv == "nil" then return "N" end
    if tv == "boolean" then return v and "B1" or "B0" end
    if tv == "number" then return "D" .. tostring(v) .. ";" end
    if tv == "string" then return "S" .. #v .. ":" .. v end
    if tv ~= "table" then error("unsupported type: " .. tv) end
    seen = seen or {}
    if seen[v] then error("cyclic table") end
    seen[v] = true
    local keys = sortedKeys(v)
    local out = { "T", tostring(#keys), ":" }
    for i = 1, #keys do
        local k = keys[i]
        out[#out + 1] = serialize(k, seen)
        out[#out + 1] = serialize(v[k], seen)
    end
    seen[v] = nil
    return table.concat(out)
end

local function readNumberUntil(s, i, delimiter)
    local j = s:find(delimiter, i, true)
    if not j then return nil, i, "delimiter" end
    local num = tonumber(s:sub(i, j - 1))
    if num == nil then return nil, i, "number" end
    return num, j + 1
end

local function deserialize(s, i, depth)
    i = i or 1
    depth = depth or 0
    if depth > 80 then return nil, i, "depth" end
    local tag = s:sub(i, i)
    if tag == "N" then return nil, i + 1 end
    if tag == "B" then
        local b = s:sub(i + 1, i + 1)
        if b == "1" then return true, i + 2 end
        if b == "0" then return false, i + 2 end
        return nil, i, "bool"
    end
    if tag == "D" then
        return readNumberUntil(s, i + 1, ";")
    end
    if tag == "S" then
        local len, nexti, err = readNumberUntil(s, i + 1, ":")
        if err then return nil, i, err end
        len = math.floor(len)
        if len < 0 or len > 16 * 1024 * 1024 then return nil, i, "string-length" end
        local last = nexti + len - 1
        if last > #s then return nil, i, "string-eof" end
        return s:sub(nexti, last), last + 1
    end
    if tag == "T" then
        local count, nexti, err = readNumberUntil(s, i + 1, ":")
        if err then return nil, i, err end
        count = math.floor(count)
        if count < 0 or count > 200000 then return nil, i, "table-size" end
        local out = {}
        i = nexti
        for _ = 1, count do
            local k, ni, e1 = deserialize(s, i, depth + 1)
            if e1 then return nil, i, e1 end
            i = ni
            local v, nj, e2 = deserialize(s, i, depth + 1)
            if e2 then return nil, i, e2 end
            i = nj
            out[k] = v
        end
        return out, i
    end
    return nil, i, "tag"
end

function C:Encode(value)
    local ok, raw = pcall(serialize, value)
    if not ok then return nil, raw end

    local lib = LibStub and LibStub("LibDeflate", true)
    if lib then
        local compressed = lib:CompressDeflate(raw, { level = 1 })
        if compressed then return TUI.Const.EXPORT_PREFIX .. "D:" .. lib:EncodeForPrint(compressed) end
    end
    return TUI.Const.EXPORT_PREFIX .. "B:" .. b64encode(raw)
end

function C:Decode(text)
    if type(text) ~= "string" then return nil, "not-string" end
    text = TUI.Utils.Trim(text)
    if text:sub(1, #TUI.Const.EXPORT_PREFIX) ~= TUI.Const.EXPORT_PREFIX then return nil, "not-tui" end
    local body = text:sub(#TUI.Const.EXPORT_PREFIX + 1)
    local mode = body:sub(1, 2)
    local payload = body:sub(3)
    local raw, err
    if mode == "D:" then
        local lib = LibStub and LibStub("LibDeflate", true)
        if not lib then return nil, "libdeflate-missing" end
        local decoded = lib:DecodeForPrint(payload)
        if not decoded then return nil, "decode" end
        raw = lib:DecompressDeflate(decoded)
        if not raw then return nil, "decompress" end
    elseif mode == "B:" then
        raw, err = b64decode(payload)
        if not raw then return nil, err end
    else
        return nil, "mode"
    end

    local value, nexti, derr = deserialize(raw, 1, 0)
    if derr then return nil, derr end
    if nexti <= #raw then return nil, "trailing-data" end
    return value
end
