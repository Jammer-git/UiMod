local Prefs = import('/lua/user/prefs.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

function Save(ProfileName, PanelLazyvar)
    positionToBeSaved = getCurrentPositions(ProfileName, PanelLazyvar)
    Prefs.SetToCurrentProfile(ProfileName, positionToBeSaved)
    LOG("SavePostion.lua Save Prefs.ProfileName: " ..repr(ProfileName).. " Saving Positions: " .. repr(positionToBeSaved))
    SavePreferences()
end

function SaveRotation(ProfileName, Number)
    rotationToBeSaved = getCurrentRotation(ProfileName, Number)
    Prefs.SetToCurrentProfile(ProfileName, rotationToBeSaved)
    LOG("SavePostion.lua Save Prefs.ProfileName: " ..repr(ProfileName).. " Saving Rotation: " .. repr(rotationToBeSaved))
    SavePreferences()
end

function getCurrentPositions(ProfileName, PanelLazyvar)
    currentPosition = { 
        savedTable = true,
        left=PanelLazyvar.Left(),
        top=PanelLazyvar.Top(),        
        right=PanelLazyvar.Right(), 
        bottom=PanelLazyvar.Bottom() 
        }
    return currentPosition
end

function getCurrentRotation(ProfileName, Number)
    currentRotation = {
        savedRotation = Number
    }
    return currentRotation
end

function saveToPrefs(profileName, panel, hidden)
    LOG("SavePostion.lua Save Prefs. hidden: " ..repr(hidden))
    saveSetup = getPanelSetup(profileName, panel, hidden)
    Prefs.SetToCurrentProfile(profileName, saveSetup)
    LOG("SavePostion.lua Save Prefs.ProfileName: " ..repr(profileName).. " Saving Positions: " .. repr(saveSetup))
    SavePreferences()
end

function getPanelSetup(profileName, panel, hidden)
    local setup = { 
        savedPrefs = true,
        hidden = hidden,
        left=panel.Left(),
        top=panel.Top(),        
        right=panel.Right(), 
        bottom=panel.Bottom() 
        }
    return setup
end