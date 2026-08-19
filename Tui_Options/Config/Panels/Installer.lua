local TUI = TUI
local O = TUI.Options

function O:BuildInstaller(parent)
    local W = self.Widgets
    local title = W:Label(parent, "Installer", 22, self.Theme.colors.accent)
    title:SetPoint("TOPLEFT", 24, -24)
    local body = W:Label(parent,
        "L'installateur complet sera construit sur DisplayGuard. Il ne s'ouvrira jamais automatiquement pendant une cinématique, un chargement ou un combat. P1 expose volontairement uniquement cette base sécurisée.",
        13, self.Theme.colors.textMuted)
    body:SetWidth(610)
    body:SetWordWrap(true)
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
end
