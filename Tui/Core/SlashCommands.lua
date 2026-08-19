local TUI = TUI

function TUI:OpenOptions(panel)
    local loaded = false
    if C_AddOns and C_AddOns.IsAddOnLoaded then loaded = C_AddOns.IsAddOnLoaded("Tui_Options")
    elseif IsAddOnLoaded then loaded = IsAddOnLoaded("Tui_Options") end

    if not loaded then
        local ok, reason
        if C_AddOns and C_AddOns.LoadAddOn then ok, reason = C_AddOns.LoadAddOn("Tui_Options")
        elseif LoadAddOn then ok, reason = LoadAddOn("Tui_Options") end
        if not ok then self:Print("Impossible de charger Tui_Options:", reason or "unknown"); return end
    end

    if self.Options and self.Options.Show then self.Options:Show(panel) end
end

SLASH_TUI1 = "/tui"
SLASH_TUI2 = "/tu"
SlashCmdList.TUI = function(msg)
    msg = TUI.Utils.Trim(msg or "")
    if msg == "" then TUI:OpenOptions(); return end
    if msg == "profile" or msg == "profiles" then TUI:OpenOptions("Profiles"); return end
    if msg == "modules" then TUI:OpenOptions("Modules"); return end
    if msg == "install" then TUI:OpenOptions("Installer"); return end
    if msg == "debug" then TUI.debug = not TUI.debug; TUI:Print("Debug:", TUI.debug and "ON" or "OFF"); return end
    TUI:Print("/tui, /tui profiles, /tui modules, /tui install")
end
