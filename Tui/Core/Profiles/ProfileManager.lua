local TUI = TUI
local U = TUI.Utils
local DB = TUI.Database

TUI.ProfileManager = TUI.ProfileManager or {}
local P = TUI.ProfileManager

function P:GetCurrentSpecID()
    local index
    if C_SpecializationInfo and C_SpecializationInfo.GetSpecialization then
        index = C_SpecializationInfo.GetSpecialization()
    elseif GetSpecialization then
        index = GetSpecialization()
    end
    if not index then return 0 end
    if C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo then
        local id = C_SpecializationInfo.GetSpecializationInfo(index)
        return id or 0
    elseif GetSpecializationInfo then
        local id = GetSpecializationInfo(index)
        return id or 0
    end
    return 0
end

function P:MakeUniqueName(requested)
    local name = U.SanitizeName(requested, "Profile")
    if not DB:GetProfile(name) then return name end
    local base, n = name, 2
    while DB:GetProfile(base .. " " .. n) do n = n + 1 end
    return base .. " " .. n
end

function P:List()
    return TuiDB.profiles.order, TuiDB.profiles.named
end

function P:Create(name, sourceName)
    local finalName = self:MakeUniqueName(name)
    local source = sourceName and DB:GetProfile(sourceName) or TUI.profile or TUI.DefaultProfile
    TuiDB.profiles.named[finalName] = U.DeepCopy(source)
    TuiDB.profiles.named[finalName].meta = TuiDB.profiles.named[finalName].meta or {}
    TuiDB.profiles.named[finalName].meta.source = "user"
    TuiDB.profiles.named[finalName].meta.modifiedVersion = TUI.version
    table.insert(TuiDB.profiles.order, finalName)
    TUI:Fire("TUI_PROFILE_LIST_CHANGED")
    return finalName
end

function P:Duplicate(sourceName, newName)
    if not DB:GetProfile(sourceName) then return false, "profile-not-found" end
    return true, self:Create(newName or (sourceName .. " Copy"), sourceName)
end

function P:Rename(oldName, newName)
    if oldName == "Default" then return false, "default" end
    local profile = DB:GetProfile(oldName)
    if not profile then return false, "profile-not-found" end
    newName = U.SanitizeName(newName, oldName)
    if newName ~= oldName and DB:GetProfile(newName) then return false, "exists" end

    TuiDB.profiles.named[newName] = profile
    if newName ~= oldName then TuiDB.profiles.named[oldName] = nil end
    for i = 1, #TuiDB.profiles.order do
        if TuiDB.profiles.order[i] == oldName then TuiDB.profiles.order[i] = newName end
    end
    for charKey, active in pairs(TuiDB.profiles.activeByCharacter) do
        if active == oldName then TuiDB.profiles.activeByCharacter[charKey] = newName end
    end
    for _, map in pairs(TuiDB.profiles.specAssignments) do
        for specID, assigned in pairs(map) do if assigned == oldName then map[specID] = newName end end
    end
    DB:BindActiveProfile()
    TUI:Fire("TUI_PROFILE_LIST_CHANGED")
    return true
end

function P:Delete(name)
    if name == "Default" then return false, "default" end
    if not DB:GetProfile(name) then return false, "profile-not-found" end
    TuiDB.profiles.named[name] = nil
    for i = #TuiDB.profiles.order, 1, -1 do if TuiDB.profiles.order[i] == name then table.remove(TuiDB.profiles.order, i) end end
    for charKey, active in pairs(TuiDB.profiles.activeByCharacter) do
        if active == name then TuiDB.profiles.activeByCharacter[charKey] = "Default" end
    end
    for _, map in pairs(TuiDB.profiles.specAssignments) do
        for specID, assigned in pairs(map) do if assigned == name then map[specID] = nil end end
    end
    DB:BindActiveProfile()
    TUI:Fire("TUI_PROFILE_LIST_CHANGED")
    return true
end

function P:Switch(name, options)
    options = options or {}
    local profile = DB:GetProfile(name)
    if not profile then return false, "profile-not-found" end
    local old = TUI.profileName
    DB:SetActiveProfileName(name)
    DB:BindActiveProfile()
    if options.applyModules ~= false then TUI.DependencyManager:ApplyProfile(profile) end
    TUI:Fire("TUI_PROFILE_CHANGED", name, old, profile)
    return true
end

function P:AssignSpec(specID, profileName)
    specID = tonumber(specID)
    if not specID or specID <= 0 or not DB:GetProfile(profileName) then return false end
    local charKey = U.GetCharacterKey()
    TuiDB.profiles.specAssignments[charKey] = TuiDB.profiles.specAssignments[charKey] or {}
    TuiDB.profiles.specAssignments[charKey][specID] = profileName
    TUI:Fire("TUI_PROFILE_ASSIGNMENTS_CHANGED", specID, profileName)
    return true
end

function P:UnassignSpec(specID)
    local charKey = U.GetCharacterKey()
    local map = TuiDB.profiles.specAssignments[charKey]
    if map then map[tonumber(specID) or specID] = nil end
end

function P:GetAssignedProfile(specID)
    local map = TuiDB.profiles.specAssignments[U.GetCharacterKey()]
    return map and map[tonumber(specID) or specID]
end

function P:ApplySpecAssignment()
    local specID = self:GetCurrentSpecID()
    if specID == 0 then return false end
    local name = self:GetAssignedProfile(specID)
    if name and name ~= TUI.profileName and DB:GetProfile(name) then
        return self:Switch(name, { applyModules = true })
    end
    return false
end
