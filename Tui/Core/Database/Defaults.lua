local TUI = TUI

TUI.DefaultProfile = {
    meta = {
        createdBy = "Tui",
        createdVersion = TUI.version,
        modifiedVersion = TUI.version,
        source = "builtin",
    },
    theme = {
        name = "AzureDark",
        accent = { 0.125, 0.663, 1.000, 1.0 },
        darkMode = true,
    },
    layout = {
        preset = "balanced",
        elements = {},
    },
    modules = {
        ["Tui.UnitFrames"] = true,
        ["Tui.ResourceBars"] = true,
        ["Tui.GroupFrames"] = true,
        ["Tui.Nameplates"] = true,
        ["Tui.Cooldown"] = true,
        ["Tui.Housing"] = true,
        ["Tui_ActionBars"] = true,
        ["Tui_CastBars"] = true,
        ["Tui_DamageMeter"] = false,
        ["Tui_Qol"] = true,
        ["Tui_Sync"] = false,
    },
    components = {
        ["Tui.Core"] = {
            automation = {
                roleAdaptive = true,
                specAdaptive = true,
                contentAdaptive = false,
                moveFramesAutomatically = false,
            },
        },
        ["Tui.UnitFrames"] = {
            style = "Tui",
            healthText = "percent-current",
            player = { enabled = true },
            target = { enabled = true },
            focus = { enabled = true },
            pet = { enabled = true },
        },
        ["Tui.ResourceBars"] = {
            enabled = true,
            primaryStyle = "thin",
            classStyle = "segments",
            detached = false,
        },
        ["Tui.GroupFrames"] = {
            partyStyle = "standard",
            raidStyle = "standard",
        },
        ["Tui.Nameplates"] = { style = "clean" },
        ["Tui.Cooldown"] = { style = "default" },
        ["Tui_ActionBars"] = { style = "minimal", bars = 3 },
        ["Tui_CastBars"] = { style = "azure" },
        ["Tui_DamageMeter"] = { visible = true },
        ["Tui_Qol"] = {},
        ["Tui_Sync"] = {},
        ["Tui.Housing"] = {},
    },
}

TUI.Defaults = {
    schemaVersion = TUI.schemaVersion,
    global = {
        installation = {
            completed = false,
            completedVersion = nil,
            welcomeDismissed = false,
        },
        display = {
            lastSeenWhatsNew = nil,
        },
        modules = {
            pendingReload = false,
        },
    },
    profiles = {
        named = {},
        order = {},
        activeByCharacter = {},
        specAssignments = {},
    },
    presets = {
        custom = {},
        order = {},
    },
}
