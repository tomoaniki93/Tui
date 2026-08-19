local TUI = TUI
local O = TUI.Options

local PANELS = { "Dashboard", "Profiles", "Modules", "Presets", "Installer" }
local builders = {
    Dashboard = "BuildDashboard",
    Profiles = "BuildProfiles",
    Modules = "BuildModules",
    Presets = "BuildPresets",
    Installer = "BuildInstaller",
}

local function clearChildren(frame)
    local children = { frame:GetChildren() }
    for i = 1, #children do children[i]:Hide(); children[i]:SetParent(nil) end
    local regions = { frame:GetRegions() }
    for i = 1, #regions do regions[i]:Hide() end
end

function O:Create()
    if self.frame then return self.frame end
    local f = CreateFrame("Frame", "TuiOptionsFrame", UIParent, "BackdropTemplate")
    f:SetSize(900, 620)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:Hide()
    self:SetBackdrop(f, "main")
    self.frame = f

    local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", -1, -1)
    header:SetHeight(52)
    self:SetBackdrop(header, "panel")

    local title = self.Widgets:Label(header, "Tui", 22, self.Theme.colors.accent)
    title:SetPoint("LEFT", 18, 0)
    local close = self.Widgets:Button(header, "×", 36, 30, function() f:Hide() end)
    close:SetPoint("RIGHT", -12, 0)

    local nav = CreateFrame("Frame", nil, f, "BackdropTemplate")
    nav:SetPoint("TOPLEFT", 1, -54)
    nav:SetPoint("BOTTOMLEFT", 1, 1)
    nav:SetWidth(190)
    self:SetBackdrop(nav, "panel")

    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", nav, "TOPRIGHT", 2, 0)
    content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    self.content = content

    for i = 1, #PANELS do
        local name = PANELS[i]
        local b = self.Widgets:Button(nav, name, 160, 30, function() O:ShowPanel(name) end)
        b:SetPoint("TOPLEFT", 14, -18 - ((i - 1) * 38))
    end

    f:SetScript("OnShow", function() O:ShowPanel(O.currentPanel or "Dashboard") end)
    return f
end

function O:ShowPanel(name)
    self.currentPanel = builders[name] and name or "Dashboard"
    clearChildren(self.content)
    local method = builders[self.currentPanel]
    if method and self[method] then self[method](self, self.content) end
end

function O:Refresh(name)
    if self.frame and self.frame:IsShown() then self:ShowPanel(name or self.currentPanel) end
end

function O:Show(panel)
    local f = self:Create()
    if panel then self.currentPanel = panel end
    f:Show()
end
