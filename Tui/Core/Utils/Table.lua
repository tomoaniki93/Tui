local TUI = TUI
local U = TUI.Utils

function U.DeepCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local out = {}
    seen[value] = out
    for k, v in pairs(value) do
        out[U.DeepCopy(k, seen)] = U.DeepCopy(v, seen)
    end
    return out
end

function U.DeepMerge(dst, src)
    if type(dst) ~= "table" or type(src) ~= "table" then return dst end
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            U.DeepMerge(dst[k], v)
        else
            dst[k] = v
        end
    end
    return dst
end

function U.MergeDefaults(dst, defaults)
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(defaults or {}) do
        if dst[k] == nil then
            dst[k] = U.DeepCopy(v)
        elseif type(v) == "table" and type(dst[k]) == "table" then
            U.MergeDefaults(dst[k], v)
        end
    end
    return dst
end

function U.Trim(s)
    if type(s) ~= "string" then return s end
    return s:match("^%s*(.-)%s*$") or s
end

function U.SanitizeName(name, fallback)
    name = U.Trim(name or "")
    if name == "" then return fallback or "Profile" end
    name = name:gsub("[%c]", "")
    if #name > 48 then name = name:sub(1, 48) end
    return name
end

function U.GetCharacterKey()
    local name, realm
    if UnitFullName then name, realm = UnitFullName("player") end
    name = name or (UnitName and UnitName("player")) or "Player"
    if not realm or realm == "" then
        realm = GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName and GetRealmName() or "Realm"
    end
    return tostring(name) .. "-" .. tostring(realm)
end
