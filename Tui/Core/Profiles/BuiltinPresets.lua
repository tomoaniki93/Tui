local P = TUI.PresetRegistry

local function profileModules(damageMeter)
    return {
        ["Tui.UnitFrames"] = true,
        ["Tui.ResourceBars"] = true,
        ["Tui.GroupFrames"] = true,
        ["Tui.Nameplates"] = true,
        ["Tui.Cooldown"] = true,
        ["Tui.Housing"] = true,
        ["Tui_ActionBars"] = true,
        ["Tui_CastBars"] = true,
        ["Tui_DamageMeter"] = damageMeter and true or false,
        ["Tui_Qol"] = true,
        ["Tui_Sync"] = false,
    }
end

P:Register("balanced", {
    label = "Tui Balanced",
    role = "ALL",
    theme = { name = "AzureDark", darkMode = true },
    layout = { preset = "balanced", elements = {} },
    modules = profileModules(false),
    components = {
        ["Tui.UnitFrames"] = { style = "Tui", healthText = "percent-current" },
        ["Tui.ResourceBars"] = { primaryStyle = "thin", classStyle = "segments", detached = false },
        ["Tui.GroupFrames"] = { partyStyle = "standard", raidStyle = "standard" },
    },
})

P:Register("minimal", {
    label = "Tui Minimal",
    role = "ALL",
    theme = { name = "AzureDark", darkMode = true },
    layout = { preset = "minimal", elements = {} },
    modules = profileModules(false),
    components = {
        ["Tui.UnitFrames"] = { style = "Minimal", healthText = "percent-current", portrait = false, power = false },
        ["Tui.ResourceBars"] = { primaryStyle = "thin", classStyle = "segments", detached = true },
        ["Tui.GroupFrames"] = { partyStyle = "minimal", raidStyle = "minimal" },
    },
})

P:Register("tank", {
    label = "Tui Tank",
    role = "TANK",
    theme = { name = "AzureDark", darkMode = true },
    layout = { preset = "tank", elements = {} },
    modules = profileModules(true),
    components = {
        ["Tui.UnitFrames"] = { style = "Tui", healthText = "percent-current", emphasizeAbsorb = true, emphasizeTargetCast = true },
        ["Tui.ResourceBars"] = { primaryStyle = "thin", classStyle = "segments", detached = false },
        ["Tui.GroupFrames"] = { partyStyle = "compact", raidStyle = "compact", emphasizeDefensives = true },
    },
})

P:Register("healer", {
    label = "Tui Healer",
    role = "HEALER",
    theme = { name = "AzureDark", darkMode = true },
    layout = { preset = "healer", elements = {} },
    modules = profileModules(true),
    components = {
        ["Tui.UnitFrames"] = { style = "Minimal", healthText = "percent-current" },
        ["Tui.ResourceBars"] = { primaryStyle = "thin", classStyle = "segments", detached = false },
        ["Tui.GroupFrames"] = { partyStyle = "healer", raidStyle = "healer", dispels = true, hots = true, deficitHealth = true },
    },
})

P:Register("dps", {
    label = "Tui DPS",
    role = "DAMAGER",
    theme = { name = "AzureDark", darkMode = true },
    layout = { preset = "dps", elements = {} },
    modules = profileModules(true),
    components = {
        ["Tui.UnitFrames"] = { style = "Minimal", healthText = "percent-current" },
        ["Tui.ResourceBars"] = { primaryStyle = "thin", classStyle = "segments", detached = true },
        ["Tui.GroupFrames"] = { partyStyle = "compact", raidStyle = "compact" },
        ["Tui.Cooldown"] = { priority = "offensive" },
    },
})
