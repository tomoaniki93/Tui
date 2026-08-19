local TUI = TUI
local O = TUI.Options
O.Widgets = O.Widgets or {}
local W = O.Widgets

local function colorText(fs, c) fs:SetTextColor(c[1], c[2], c[3], c[4] or 1) end

function W:Label(parent, text, size, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetText(text or "")
    fs:SetFont(STANDARD_TEXT_FONT, size or 13, "")
    colorText(fs, color or O.Theme.colors.text)
    fs:SetJustifyH("LEFT")
    return fs
end

function W:Button(parent, text, width, height, onClick)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(width or 120, height or 30)
    O:SetBackdrop(b, "panel")
    local label = self:Label(b, text, 12)
    label:SetPoint("CENTER")
    b.label = label
    b:SetScript("OnEnter", function(self)
        local c = O.Theme.colors.accent
        self:SetBackdropBorderColor(c[1], c[2], c[3], 1)
    end)
    b:SetScript("OnLeave", function(self)
        local c = O.Theme.colors.border
        self:SetBackdropBorderColor(c[1], c[2], c[3], 1)
    end)
    if onClick then b:SetScript("OnClick", onClick) end
    return b
end

function W:Toggle(parent, labelText, value, onChanged)
    local f = CreateFrame("Button", nil, parent)
    f:SetSize(210, 26)
    local label = self:Label(f, labelText, 12)
    label:SetPoint("LEFT", 0, 0)

    local track = CreateFrame("Frame", nil, f, "BackdropTemplate")
    track:SetSize(40, 20)
    track:SetPoint("RIGHT", 0, 0)
    track:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })

    local knob = track:CreateTexture(nil, "OVERLAY")
    knob:SetColorTexture(1, 1, 1, 1)
    knob:SetSize(14, 14)

    local function draw(v)
        f.value = v and true or false
        local c = f.value and O.Theme.colors.accent or O.Theme.colors.border
        track:SetBackdropColor(c[1], c[2], c[3], 0.85)
        track:SetBackdropBorderColor(c[1], c[2], c[3], 1)
        knob:ClearAllPoints()
        knob:SetPoint(f.value and "RIGHT" or "LEFT", track, f.value and "RIGHT" or "LEFT", f.value and -3 or 3, 0)
    end
    f.SetValue = function(_, v) draw(v) end
    draw(value)
    f:SetScript("OnClick", function(self)
        draw(not self.value)
        if onChanged then onChanged(self.value) end
    end)
    return f
end
