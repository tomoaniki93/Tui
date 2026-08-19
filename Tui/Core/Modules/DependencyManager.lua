local TUI = TUI
local R = TUI.ModuleRegistry

TUI.DependencyManager = TUI.DependencyManager or {}
local D = TUI.DependencyManager

local function getAddonInfo(name)
    if C_AddOns and C_AddOns.GetAddOnInfo then
        return C_AddOns.GetAddOnInfo(name)
    elseif GetAddOnInfo then
        return GetAddOnInfo(name)
    end
end

local function isAddonLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then return C_AddOns.IsAddOnLoaded(name) end
    if IsAddOnLoaded then return IsAddOnLoaded(name) end
    return false
end

local function setAddonEnabled(name, enabled)
    if C_AddOns then
        if enabled and C_AddOns.EnableAddOn then C_AddOns.EnableAddOn(name); return true end
        if not enabled and C_AddOns.DisableAddOn then C_AddOns.DisableAddOn(name); return true end
    end
    if enabled and EnableAddOn then EnableAddOn(name); return true end
    if not enabled and DisableAddOn then DisableAddOn(name); return true end
    return false
end

function D:IsInstalled(id)
    local entry = R:Get(id)
    if not entry then return false end
    if entry.internal then return true end
    if not entry.addon then return true end
    if C_AddOns and C_AddOns.DoesAddOnExist then
        return C_AddOns.DoesAddOnExist(entry.addon) == true
    end
    local name = getAddonInfo(entry.addon)
    return name ~= nil
end

function D:IsLoaded(id)
    local entry = R:Get(id)
    if not entry then return false end
    if entry.internal then return true end
    return entry.addon and isAddonLoaded(entry.addon) or false
end

function D:SetDesiredState(id, enabled)
    local entry = R:Get(id)
    if not entry or entry.required then return false, "locked" end
    if not R:SetDesiredEnabled(id, enabled) then return false, "profile" end

    if entry.addon and self:IsInstalled(id) then
        local ok = setAddonEnabled(entry.addon, enabled)
        if ok and entry.reload then TuiDB.global.modules.pendingReload = true end
    end
    return true
end

function D:ApplyProfile(profile)
    profile = profile or TUI.profile
    if not profile then return false end
    local changed = false
    for _, id in ipairs(R.order) do
        local entry = R.entries[id]
        if entry.addon and self:IsInstalled(id) then
            local desired = R:IsDesiredEnabled(id, profile)
            if setAddonEnabled(entry.addon, desired) and entry.reload then changed = true end
        end
    end
    if changed then TuiDB.global.modules.pendingReload = true end
    return true
end

function D:HasPendingReload()
    return TuiDB and TuiDB.global and TuiDB.global.modules.pendingReload == true
end

function D:ClearPendingReload()
    if TuiDB and TuiDB.global then TuiDB.global.modules.pendingReload = false end
end
