local TUI = TUI
local O = TUI.Options

function O:BuildProfiles(parent)
    local W = self.Widgets
    local title = W:Label(parent, "Profiles", 22, self.Theme.colors.accent)
    title:SetPoint("TOPLEFT", 24, -24)

    local active = W:Label(parent, "Actif : " .. tostring(TUI.profileName), 13)
    active:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    parent.activeLabel = active

    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(220, 30)
    input:SetPoint("TOPLEFT", active, "BOTTOMLEFT", 4, -24)
    input:SetAutoFocus(false)
    input:SetText("Nouveau profil")

    local create = W:Button(parent, "Créer depuis l'actuel", 170, 30, function()
        local name = TUI.ProfileManager:Create(input:GetText(), TUI.profileName)
        TUI.ProfileManager:Switch(name)
        if O.Refresh then O:Refresh("Profiles") end
    end)
    create:SetPoint("LEFT", input, "RIGHT", 12, 0)

    local assign = W:Button(parent, "Assigner à cette spécialisation", 220, 30, function()
        local specID = TUI.ProfileManager:GetCurrentSpecID()
        if specID > 0 then
            TUI.ProfileManager:AssignSpec(specID, TUI.profileName)
            TUI:Print("Profil", TUI.profileName, "assigné à la spécialisation", specID)
        end
    end)
    assign:SetPoint("TOPLEFT", input, "BOTTOMLEFT", -4, -18)

    local y = -150
    local order = TuiDB.profiles.order
    for i = 1, math.min(#order, 10) do
        local name = order[i]
        local b = W:Button(parent, name, 260, 28, function()
            TUI.ProfileManager:Switch(name)
            if O.Refresh then O:Refresh("Profiles") end
        end)
        b:SetPoint("TOPLEFT", 24, y)
        y = y - 34
    end
end
