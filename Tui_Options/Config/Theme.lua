local TUI = TUI
TUI.Options = TUI.Options or {}
local O = TUI.Options

O.Theme = TUI.ThemeDefaults

function O:SetBackdrop(frame, kind)
    local c = self.Theme.colors
    frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    local bg = kind == "main" and c.background or c.panel
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    frame:SetBackdropBorderColor(c.border[1], c.border[2], c.border[3], 1)
end
