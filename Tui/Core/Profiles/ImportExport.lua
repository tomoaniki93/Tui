local TUI = TUI
local U = TUI.Utils
local Codec = TUI.ProfileCodec

TUI.ImportExport = TUI.ImportExport or {}
local IE = TUI.ImportExport

local function currentClassSpec()
    local class = select(2, UnitClass and UnitClass("player")) or "UNKNOWN"
    local specID = TUI.ProfileManager and TUI.ProfileManager:GetCurrentSpecID() or 0
    return class, specID
end

local function buildMeta(kind, name)
    local class, specID = currentClassSpec()
    return {
        kind = kind,
        name = name,
        author = UnitName and UnitName("player") or "",
        class = class,
        specID = specID,
        version = TUI.version,
        exported = date and date("%Y-%m-%d %H:%M") or "",
    }
end

local function envelope(kind, name, data)
    return {
        header = "TUI",
        schema = TUI.Const.EXPORT_SCHEMA,
        kind = kind,
        meta = buildMeta(kind, name),
        data = data,
    }
end

function IE:ExportProfile(profileName)
    local profile = TUI.Database:GetProfile(profileName or TUI.profileName)
    if not profile then return nil, "profile-not-found" end
    return Codec:Encode(envelope("profile", profileName or TUI.profileName, U.DeepCopy(profile)))
end

function IE:ExportPreset(presetID)
    local preset = TUI.PresetRegistry:Get(presetID)
    if not preset then return nil, "preset-not-found" end
    return Codec:Encode(envelope("preset", preset.label or presetID, U.DeepCopy(preset)))
end

function IE:Preview(text)
    local payload, err = Codec:Decode(text)
    if not payload then return nil, err end
    if payload.header ~= "TUI" then return nil, "header" end
    if tonumber(payload.schema) ~= TUI.Const.EXPORT_SCHEMA then return nil, "schema" end
    if payload.kind ~= "profile" and payload.kind ~= "preset" then return nil, "kind" end
    if type(payload.data) ~= "table" then return nil, "data" end

    return {
        kind = payload.kind,
        meta = payload.meta or {},
        modules = U.DeepCopy(payload.data.modules or {}),
        components = U.DeepCopy(payload.data.components or {}),
        hasTheme = payload.data.theme ~= nil,
        hasLayout = payload.data.layout ~= nil,
        _payload = payload,
    }
end

local function selected(selection, key, default)
    if not selection then return default end
    local v = selection[key]
    if v == nil then return default end
    return v == true
end

function IE:ImportProfile(text, options)
    options = options or {}
    local preview, err = self:Preview(text)
    if not preview then return false, err end
    if preview.kind ~= "profile" then return false, "not-profile" end

    local source = preview._payload.data
    local name = U.SanitizeName(options.name or (preview.meta and preview.meta.name), "Imported")
    local base = options.mergeInto and TUI.Database:GetProfile(options.mergeInto) or nil
    local target = base and U.DeepCopy(base) or U.DeepCopy(TUI.DefaultProfile)

    if selected(options.sections, "theme", true) and source.theme then target.theme = U.DeepCopy(source.theme) end
    if selected(options.sections, "layout", true) and source.layout then target.layout = U.DeepCopy(source.layout) end

    target.components = target.components or {}
    for componentID, data in pairs(source.components or {}) do
        if not options.componentSelection or options.componentSelection[componentID] ~= false then
            target.components[componentID] = U.DeepCopy(data)
        end
    end

    if selected(options.sections, "modules", true) then
        target.modules = target.modules or {}
        for moduleID, state in pairs(source.modules or {}) do
            local choice = options.moduleSelection and options.moduleSelection[moduleID]
            if choice == nil then choice = true end
            if choice then target.modules[moduleID] = state == true end
        end
    end

    target.meta = target.meta or {}
    target.meta.source = "import"
    target.meta.importedVersion = preview.meta and preview.meta.version or nil
    target.meta.modifiedVersion = TUI.version

    local finalName = TUI.ProfileManager:MakeUniqueName(name)
    TuiDB.profiles.named[finalName] = target
    table.insert(TuiDB.profiles.order, finalName)

    if options.activate ~= false then
        TUI.ProfileManager:Switch(finalName, { applyModules = options.applyModules ~= false })
    end
    return true, finalName
end

function IE:ImportPreset(text, options)
    options = options or {}
    local preview, err = self:Preview(text)
    if not preview then return false, err end
    if preview.kind ~= "preset" then return false, "not-preset" end
    local source = preview._payload.data
    local id = U.SanitizeName(options.id or source.id or preview.meta.name, "Custom")
    local baseID, n = id, 2
    while TUI.PresetRegistry:Get(id) do id = baseID .. " " .. n; n = n + 1 end
    source = U.DeepCopy(source)
    source.id = id
    source.kind = "custom"
    TuiDB.presets.custom[id] = source
    table.insert(TuiDB.presets.order, id)
    return true, id
end
