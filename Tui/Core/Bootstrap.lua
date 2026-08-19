local addonName, ns = ...

TUI = TUI or {}
local TUI = TUI

TUI.name = addonName or "Tui"
TUI.ns = ns or {}
TUI.version = "0.1.0"
TUI.schemaVersion = 1
TUI.debug = false

TUI.Modules = TUI.Modules or {}
TUI.Profiles = TUI.Profiles or {}
TUI.Presets = TUI.Presets or {}
TUI.Display = TUI.Display or {}
TUI.Utils = TUI.Utils or {}
TUI.Callbacks = TUI.Callbacks or {}

function TUI:Print(...)
    local prefix = "|cff20A9FFTui|r"
    print(prefix, ...)
end

function TUI:Debug(...)
    if self.debug then
        self:Print("|cff91A8B9[Debug]|r", ...)
    end
end

function TUI:RegisterCallback(event, owner, fn)
    if type(event) ~= "string" or type(fn) ~= "function" then return end
    self.Callbacks[event] = self.Callbacks[event] or {}
    table.insert(self.Callbacks[event], { owner = owner, fn = fn })
end

function TUI:Fire(event, ...)
    local list = self.Callbacks[event]
    if not list then return end
    for i = 1, #list do
        local entry = list[i]
        local ok, err = pcall(entry.fn, entry.owner, ...)
        if not ok then self:Debug("Callback failed:", event, err) end
    end
end
