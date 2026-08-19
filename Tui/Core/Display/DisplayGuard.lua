local TUI = TUI
local S = TUI.Display.StateTracker

TUI.Display.Guard = TUI.Display.Guard or {}
local G = TUI.Display.Guard

function G:CanShow(level)
    level = level or TUI.Const.DISPLAY_INTERACTIVE
    if S:IsLoading() then return false, "loading" end
    if S:IsCinematic() then return false, "cinematic" end

    if level == TUI.Const.DISPLAY_SAFE then
        return true
    end

    if S:IsCombat() then return false, "combat" end
    return true
end
