local TUI = TUI

TUI.ModuleRegistry = TUI.ModuleRegistry or { order = {}, entries = {} }
local R = TUI.ModuleRegistry

function R:Register(id, info)
    if type(id) ~= "string" or id == "" then return false end
    info = info or {}
    if not self.entries[id] then table.insert(self.order, id) end
    info.id = id
    self.entries[id] = info
    return true
end

function R:Get(id)
    return self.entries[id]
end

function R:GetAll()
    return self.order, self.entries
end

function R:IsDesiredEnabled(id, profile)
    profile = profile or TUI.profile
    if not profile then return false end
    if self.entries[id] and self.entries[id].required then return true end
    return profile.modules and profile.modules[id] == true
end

function R:SetDesiredEnabled(id, enabled, profile)
    profile = profile or TUI.profile
    local entry = self.entries[id]
    if not profile or not entry or entry.required then return false end
    profile.modules = profile.modules or {}
    profile.modules[id] = enabled and true or false
    TUI:Fire("TUI_MODULE_DESIRED_STATE_CHANGED", id, profile.modules[id])
    return true
end

-- Built-in/internal modules
R:Register("Tui.Core", { label = "Tui Core", category = "Core", required = true, internal = true })
R:Register("Tui.UnitFrames", { label = "Unit Frames", category = "Interface", internal = true })
R:Register("Tui.ResourceBars", { label = "Resource Bars", category = "Interface", internal = true })
R:Register("Tui.GroupFrames", { label = "Party & Raid", category = "Interface", internal = true })
R:Register("Tui.Nameplates", { label = "Nameplates", category = "Interface", internal = true })
R:Register("Tui.Cooldown", { label = "Cooldown", category = "Interface", internal = true })
R:Register("Tui.Housing", { label = "Housing", category = "Utility", internal = true })

-- External Tui addons. Their desired state is profile-aware and may need /reload.
R:Register("Tui_ActionBars", { label = "Action Bars", category = "Addons", addon = "Tui_ActionBars", reload = true })
R:Register("Tui_CastBars", { label = "Cast Bars", category = "Addons", addon = "Tui_CastBars", reload = true })
R:Register("Tui_DamageMeter", { label = "Damage Meter", category = "Addons", addon = "Tui_DamageMeter", reload = true })
R:Register("Tui_Qol", { label = "Quality of Life", category = "Addons", addon = "Tui_Qol", reload = true })
R:Register("Tui_Sync", { label = "Sync", category = "Addons", addon = "Tui_Sync", reload = true })
