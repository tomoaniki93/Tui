local TUI = TUI
local U = TUI.Utils

TUI.Database = TUI.Database or {}
local DB = TUI.Database

local function ensureDefaultProfile()
    local p = TuiDB.profiles
    if not p.named.Default then
        p.named.Default = U.DeepCopy(TUI.DefaultProfile)
    else
        U.MergeDefaults(p.named.Default, TUI.DefaultProfile)
    end

    local hasDefault = false
    for i = 1, #p.order do
        if p.order[i] == "Default" then hasDefault = true; break end
    end
    if not hasDefault then table.insert(p.order, 1, "Default") end
end

function DB:Initialize()
    TuiDB = type(TuiDB) == "table" and TuiDB or {}
    U.MergeDefaults(TuiDB, TUI.Defaults)
    TuiDB.schemaVersion = TUI.schemaVersion
    ensureDefaultProfile()
end

function DB:GetProfile(name)
    if not TuiDB or not TuiDB.profiles then return nil end
    return TuiDB.profiles.named[name]
end

function DB:GetActiveProfileName()
    local key = U.GetCharacterKey()
    local name = TuiDB.profiles.activeByCharacter[key]
    if name and TuiDB.profiles.named[name] then return name end
    TuiDB.profiles.activeByCharacter[key] = "Default"
    return "Default"
end

function DB:SetActiveProfileName(name)
    if not self:GetProfile(name) then return false end
    TuiDB.profiles.activeByCharacter[U.GetCharacterKey()] = name
    return true
end

function DB:BindActiveProfile()
    local name = self:GetActiveProfileName()
    local profile = self:GetProfile(name)
    TUI.profileName = name
    TUI.profile = profile
    TUI.db = profile and profile.components or nil
    return profile
end

function TUI:GetConfig(componentID)
    local profile = self.profile or DB:BindActiveProfile()
    if not profile then return nil end
    profile.components = profile.components or {}
    profile.components[componentID] = profile.components[componentID] or {}
    return profile.components[componentID]
end
