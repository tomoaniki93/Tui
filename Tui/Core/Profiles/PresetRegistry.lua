local TUI = TUI
local U = TUI.Utils

TUI.PresetRegistry = TUI.PresetRegistry or { builtins = {}, order = {} }
local P = TUI.PresetRegistry

function P:Register(id, data)
    if type(id) ~= "string" or type(data) ~= "table" then return false end
    if not self.builtins[id] then table.insert(self.order, id) end
    data.id = id
    self.builtins[id] = data
    return true
end

function P:Get(id)
    if self.builtins[id] then return self.builtins[id], "builtin" end
    if TuiDB and TuiDB.presets and TuiDB.presets.custom[id] then
        return TuiDB.presets.custom[id], "custom"
    end
end

function P:CreateCustom(id, displayName, sourceProfile, componentSelection)
    sourceProfile = sourceProfile or TUI.profile
    if not sourceProfile then return false, "profile" end
    id = U.SanitizeName(id, displayName or "Custom")
    if id == "" then return false, "name" end

    local preset = {
        id = id,
        label = U.SanitizeName(displayName, id),
        kind = "custom",
        meta = { createdVersion = TUI.version, created = date and date("%Y-%m-%d %H:%M") or "" },
        theme = U.DeepCopy(sourceProfile.theme),
        layout = U.DeepCopy(sourceProfile.layout),
        modules = U.DeepCopy(sourceProfile.modules),
        components = {},
    }

    for componentID, data in pairs(sourceProfile.components or {}) do
        if not componentSelection or componentSelection[componentID] ~= false then
            preset.components[componentID] = U.DeepCopy(data)
        end
    end

    TuiDB.presets.custom[id] = preset
    local found = false
    for i = 1, #TuiDB.presets.order do if TuiDB.presets.order[i] == id then found = true end end
    if not found then table.insert(TuiDB.presets.order, id) end
    return true, preset
end

function P:DeleteCustom(id)
    if not TuiDB.presets.custom[id] then return false end
    TuiDB.presets.custom[id] = nil
    for i = #TuiDB.presets.order, 1, -1 do
        if TuiDB.presets.order[i] == id then table.remove(TuiDB.presets.order, i) end
    end
    return true
end

function P:Apply(id, targetProfile, options)
    local preset = self:Get(id)
    if not preset or not targetProfile then return false end
    options = options or {}

    if options.theme ~= false and preset.theme then targetProfile.theme = U.DeepCopy(preset.theme) end
    if options.layout ~= false and preset.layout then targetProfile.layout = U.DeepCopy(preset.layout) end
    if options.modules ~= false and preset.modules then targetProfile.modules = U.DeepCopy(preset.modules) end

    targetProfile.components = targetProfile.components or {}
    for componentID, data in pairs(preset.components or {}) do
        if not options.components or options.components[componentID] ~= false then
            targetProfile.components[componentID] = U.DeepCopy(data)
        end
    end
    targetProfile.meta = targetProfile.meta or {}
    targetProfile.meta.basePreset = id
    targetProfile.meta.modifiedVersion = TUI.version
    return true
end
