local TUI = TUI
local O = TUI.Options

function O:BuildPresets(parent)
    local W = self.Widgets
    local title = W:Label(parent, "Presets", 22, self.Theme.colors.accent)
    title:SetPoint("TOPLEFT", 24, -24)
    local note = W:Label(parent, "Les presets sont une base. Le profil reste ensuite entièrement personnalisable.", 12, self.Theme.colors.textMuted)
    note:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

    local y = -88
    for i = 1, #TUI.PresetRegistry.order do
        local id = TUI.PresetRegistry.order[i]
        local preset = TUI.PresetRegistry.builtins[id]
        local b = W:Button(parent, preset.label or id, 220, 30, function()
            TUI.PresetRegistry:Apply(id, TUI.profile, {})
            TUI.DependencyManager:ApplyProfile(TUI.profile)
            TUI:Fire("TUI_PROFILE_CHANGED", TUI.profileName, TUI.profileName, TUI.profile)
            TUI:Print("Preset appliqué :", preset.label or id)
        end)
        b:SetPoint("TOPLEFT", 24, y)
        y = y - 38
    end

    local custom = W:Button(parent, "Créer un preset custom", 220, 30, function()
        local id = "Custom " .. tostring(#TuiDB.presets.order + 1)
        local ok = TUI.PresetRegistry:CreateCustom(id, id, TUI.profile)
        if ok then TUI:Print("Preset custom créé :", id) end
    end)
    custom:SetPoint("TOPLEFT", 280, -88)
end
