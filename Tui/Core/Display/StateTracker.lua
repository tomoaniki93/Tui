local TUI = TUI

TUI.Display.StateTracker = TUI.Display.StateTracker or {
    inWorld = false,
    loading = true,
    cinematic = false,
    combat = false,
    generation = 0,
}
local S = TUI.Display.StateTracker

function S:Bump(reason)
    self.generation = self.generation + 1
    TUI:Fire("TUI_DISPLAY_STATE_CHANGED", reason, self)
end

function S:IsCombat()
    if InCombatLockdown and InCombatLockdown() then return true end
    return self.combat == true
end

function S:IsCinematic()
    if self.cinematic == true then return true end
    if MovieFrame and MovieFrame.IsShown and MovieFrame:IsShown() then return true end
    if CinematicFrame and CinematicFrame.IsShown and CinematicFrame:IsShown() then return true end
    return false
end

function S:IsLoading()
    return self.loading == true or not self.inWorld
end

function S:Initialize()
    if self.frame then return end
    local f = CreateFrame("Frame")
    self.frame = f
    local events = {
        "PLAYER_ENTERING_WORLD",
        "PLAYER_LEAVING_WORLD",
        "LOADING_SCREEN_ENABLED",
        "LOADING_SCREEN_DISABLED",
        "CINEMATIC_START",
        "CINEMATIC_STOP",
        "PLAYER_REGEN_DISABLED",
        "PLAYER_REGEN_ENABLED",
    }
    for i = 1, #events do pcall(f.RegisterEvent, f, events[i]) end

    f:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_ENTERING_WORLD" then S.inWorld = true; S.loading = false
        elseif event == "PLAYER_LEAVING_WORLD" then S.inWorld = false; S.loading = true
        elseif event == "LOADING_SCREEN_ENABLED" then S.loading = true
        elseif event == "LOADING_SCREEN_DISABLED" then S.loading = false
        elseif event == "CINEMATIC_START" then S.cinematic = true
        elseif event == "CINEMATIC_STOP" then S.cinematic = false
        elseif event == "PLAYER_REGEN_DISABLED" then S.combat = true
        elseif event == "PLAYER_REGEN_ENABLED" then S.combat = false
        end
        S:Bump(event)
    end)
end
