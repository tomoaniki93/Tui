local TUI = TUI
TUI.Framework = TUI.Framework or {
    version = 1,
    movers = {},
    layouts = {},
}

-- P1 foundation only. The new mover engine will live here and will be built
-- from a clean Tui implementation inspired by Cooldown Studio behavior.
function TUI.Framework:RegisterMovable(id, frame, options)
    if type(id) ~= "string" or not frame then return false end
    self.movers[id] = { frame = frame, options = options or {} }
    return true
end
