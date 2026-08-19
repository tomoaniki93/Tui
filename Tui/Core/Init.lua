local TUI = TUI

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Tui" then
        TUI.Database:Initialize()
        TUI.Database:BindActiveProfile()
        TUI.Display.StateTracker:Initialize()
        TUI:Fire("TUI_DATABASE_READY")
    elseif event == "PLAYER_LOGIN" then
        TUI.Database:BindActiveProfile()
        TUI.ProfileManager:ApplySpecAssignment()
        TUI:Fire("TUI_READY")
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and (arg1 == nil or arg1 == "player") then
        if C_Timer and C_Timer.After then
            C_Timer.After(0.25, function() TUI.ProfileManager:ApplySpecAssignment() end)
        else
            TUI.ProfileManager:ApplySpecAssignment()
        end
    end
end)
