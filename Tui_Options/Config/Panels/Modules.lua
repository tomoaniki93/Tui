local TUI = TUI
local O = TUI.Options

function O:BuildModules(parent)
    local W = self.Widgets
    local title = W:Label(parent, "Modules & Dependencies", 22, self.Theme.colors.accent)
    title:SetPoint("TOPLEFT", 24, -24)
    local note = W:Label(parent, "Les sous-addons externes sont appliqués au prochain /reload.", 12, self.Theme.colors.textMuted)
    note:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

    local y = -88
    local order, entries = TUI.ModuleRegistry:GetAll()
    for i = 1, #order do
        local id = order[i]
        local entry = entries[id]
        if id ~= "Tui.Core" then
            local installed = TUI.DependencyManager:IsInstalled(id)
            local desired = TUI.ModuleRegistry:IsDesiredEnabled(id)
            local suffix = installed and "" or "  |cff586977(non installé)|r"
            local toggle = W:Toggle(parent, entry.label .. suffix, desired, function(v)
                TUI.DependencyManager:SetDesiredState(id, v)
            end)
            toggle:SetPoint("TOPLEFT", 24, y)
            if not installed and entry.addon then toggle:Disable(); toggle:SetAlpha(0.5) end
            y = y - 32
        end
    end
end
