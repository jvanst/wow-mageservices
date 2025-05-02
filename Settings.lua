------------------------------------------
-- Settings Module
------------------------------------------
local MageService = MAGESERVICE
local Settings = {}
MageService.Settings = Settings

------------------------------------------
-- Default Settings
------------------------------------------
local defaultSettings = {
    addonEnabled = false,
    containerUIVisible = true,
    containerUIPosition = {
        point = "CENTER",
        relativePoint = "CENTER",
        xOfs = 0,
        yOfs = 100
    }
}

-- Table to store the character-specific settings
local characterSettings = {}

------------------------------------------
-- Saved Variables
------------------------------------------
-- Variables that will be saved between sessions
-- Will be initialized when ADDON_LOADED fires

------------------------------------------
-- Settings Functions
------------------------------------------

-- Initialize settings
function Settings.Initialize()
    -- Create the saved variables if they don't exist
    if MageServiceDB == nil then
        MageServiceDB = {}
    end
    
    -- Get character name and realm for unique identification
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local fullName = playerName .. "-" .. realmName
    
    -- Initialize character settings if they don't exist
    if MageServiceDB[fullName] == nil then
        MageServiceDB[fullName] = {}
        -- Copy default settings
        for key, value in pairs(defaultSettings) do
            MageServiceDB[fullName][key] = value
        end
    end
    
    -- Store reference to this character's settings
    characterSettings = MageServiceDB[fullName]
end

-- Get a setting value
function Settings.GetSetting(key)
    -- Return default if character settings not initialized
    if not characterSettings or characterSettings[key] == nil then
        return defaultSettings[key]
    end
    
    return characterSettings[key]
end

-- Set a setting value
function Settings.SetSetting(key, value)
    -- Ensure we have settings to write to
    if not characterSettings then
        Settings.Initialize()
    end
    
    -- Update the value
    characterSettings[key] = value
    
    -- Returning the value allows for method chaining
    return value
end

-- Toggle a boolean setting
function Settings.ToggleSetting(key)
    local currentValue = Settings.GetSetting(key)
    
    -- Only toggle if it's a boolean value
    if type(currentValue) == "boolean" then
        return Settings.SetSetting(key, not currentValue)
    end
    
    return currentValue
end

------------------------------------------
-- Convenience Functions for Common Settings
------------------------------------------

-- Check if the addon is enabled
function Settings.IsAddonEnabled()
    return Settings.GetSetting("addonEnabled")
end

-- Set the addon enabled state
function Settings.SetAddonEnabled(enabled)
    return Settings.SetSetting("addonEnabled", enabled)
end

-- Toggle the addon enabled state
function Settings.ToggleAddonEnabled()
    return Settings.ToggleSetting("addonEnabled")
end

-- Functions for Container UI settings
function Settings.IsContainerUIVisible()
    return Settings.GetSetting("containerUIVisible")
end

function Settings.SetContainerUIVisible(visible)
    return Settings.SetSetting("containerUIVisible", visible)
end

function Settings.GetContainerUIPosition()
    return Settings.GetSetting("containerUIPosition")
end

function Settings.SetContainerUIPosition(positionTable)
    return Settings.SetSetting("containerUIPosition", positionTable)
end

-- Handler for the ADDON_LOADED event
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "MageService" then
        Settings.Initialize()
        -- We only need to handle this event once
        self:UnregisterEvent("ADDON_LOADED")
    end
end)