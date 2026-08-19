local TUI = TUI

TUI.Const = {
    PROFILE_SCHEMA = 1,
    EXPORT_SCHEMA = 1,
    EXPORT_PREFIX = "TUI1:",

    DISPLAY_SAFE = "SAFE",
    DISPLAY_INTERACTIVE = "INTERACTIVE",
    DISPLAY_MODAL = "MODAL",

    CORE_MODULE = "Tui.Core",
}

TUI.ThemeDefaults = {
    name = "AzureDark",
    colors = {
        background = { 0.039, 0.063, 0.090, 1.0 }, -- #0A1017
        panel = { 0.063, 0.098, 0.137, 1.0 },      -- #101923
        panelHover = { 0.082, 0.137, 0.192, 1.0 },
        border = { 0.141, 0.220, 0.290, 1.0 },
        accent = { 0.125, 0.663, 1.000, 1.0 },     -- #20A9FF
        accentBright = { 0.345, 0.769, 1.000, 1.0 },
        text = { 0.918, 0.961, 0.988, 1.0 },
        textMuted = { 0.569, 0.659, 0.725, 1.0 },
        success = { 0.271, 0.831, 0.612, 1.0 },
        warning = { 1.000, 0.722, 0.302, 1.0 },
        error = { 1.000, 0.380, 0.455, 1.0 },
    },
}
