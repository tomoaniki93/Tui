local TUI = TUI
local G = TUI.Display.Guard
local S = TUI.Display.StateTracker

TUI.Display.Queue = TUI.Display.Queue or { requests = {}, timerToken = 0 }
local Q = TUI.Display.Queue

local priorities = { SAFE = 10, INTERACTIVE = 50, MODAL = 100 }

function Q:Request(id, level, callback, options)
    if type(id) ~= "string" or type(callback) ~= "function" then return false end
    options = options or {}
    self.requests[id] = {
        id = id,
        level = level or TUI.Const.DISPLAY_INTERACTIVE,
        callback = callback,
        priority = options.priority or priorities[level] or 50,
        stability = options.stability or 1.0,
    }
    self:Evaluate()
    return true
end

function Q:Cancel(id)
    self.requests[id] = nil
    self.timerToken = self.timerToken + 1
end

function Q:GetNext()
    local best
    for _, req in pairs(self.requests) do
        local ok = G:CanShow(req.level)
        if ok and (not best or req.priority > best.priority) then best = req end
    end
    return best
end

function Q:Evaluate()
    local req = self:GetNext()
    if not req then return end
    self.timerToken = self.timerToken + 1
    local token = self.timerToken
    local generation = S.generation
    local function attempt()
        if token ~= Q.timerToken or not Q.requests[req.id] then return end
        if generation ~= S.generation then Q:Evaluate(); return end
        local ok = G:CanShow(req.level)
        if not ok then return end
        Q.requests[req.id] = nil
        local success, err = pcall(req.callback)
        if not success then TUI:Debug("Display callback failed", req.id, err) end
        Q:Evaluate()
    end
    if C_Timer and C_Timer.After then C_Timer.After(req.stability, attempt) else attempt() end
end

TUI:RegisterCallback("TUI_DISPLAY_STATE_CHANGED", Q, function(self)
    self.timerToken = self.timerToken + 1
    self:Evaluate()
end)
