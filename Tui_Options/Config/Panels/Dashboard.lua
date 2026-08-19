local TUI = TUI
local O = TUI.Options

function O:BuildDashboard(parent)
    local W = self.Widgets
    local title = W:Label(parent, "Tui", 26, self.Theme.colors.accent)
    title:SetPoint("TOPLEFT", 24, -24)
    local sub = W:Label(parent, "Simple first. Powerful when needed.", 13, self.Theme.colors.textMuted)
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)

    local profile = W:Label(parent, "Profil actif : " .. tostring(TUI.profileName or "Default"), 15)
    profile:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -36)
    parent.profileLabel = profile

    local info = W:Label(parent,
        "Fondation P1 active : profils par spécialisation, presets custom, import/export, gestion des modules et DisplayGuard.",
        12, self.Theme.colors.textMuted)
    info:SetWidth(600)
    info:SetWordWrap(true)
    info:SetPoint("TOPLEFT", profile, "BOTTOMLEFT", 0, -16)

    local reload = W:Button(parent, "Appliquer et recharger", 180, 32, function()
        if ReloadUI then ReloadUI() end
    end)
    reload:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -28)
    parent.reloadButton = reload
end
