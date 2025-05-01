------------------------------------------
-- Destinations Module
------------------------------------------
local MyAddOn = MYADDON

------------------------------------------
-- Create the Destinations module
------------------------------------------
local Destinations = {}

------------------------------------------
-- Destination Data
------------------------------------------
-- This table will store the destination keywords
-- The keys are the destination names, and the values are lists of keywords
-- that can be used to identify them in messages
local destinationMap = {
    Stormwind = {"sw", "stormw", "stormwind", "storm wind"},
    Ironforge = {"if", "ironforge", "ironf"},
    Darnassus = {"darn", "darnassus", "darnas"},
}

------------------------------------------
-- Destination Functions
------------------------------------------

-- Function to find a destination in a message
function Destinations.FindInMessage(message)
    if not message or type(message) ~= "string" then
        return nil
    end
    
    -- Convert message to lowercase for case-insensitive matching
    local lowerMessage = string.lower(message)
    
    -- Check each destination
    for destination, keywords in pairs(destinationMap) do
        for _, keyword in ipairs(keywords) do
            if string.find(lowerMessage, keyword, 1, true) then
                return destination
            end
        end
    end
    
    return nil
end

------------------------------------------
-- Player Destination Tracking
------------------------------------------
-- This table will store player destinations
-- The keys will be player names (normalized), and the values will be destination names
local playerDestinations = {}

-- Function to add player destination
function Destinations.AddPlayerDestination(playerName, destination)
    if not playerName or not destination then
        return false
    end
    
    -- Normalize playerName to handle different formats
    playerName = string.lower(playerName)
    
    -- Check if destination is valid (exists in destinationMap)
    if not destinationMap[destination] then
        return false
    end
    
    -- Store the destination for this player
    playerDestinations[playerName] = destination
    return true
end

-- Function to get player destination
function Destinations.GetPlayerDestination(playerName)
    if not playerName then
        return nil
    end
    
    -- Normalize playerName to handle different formats
    playerName = string.lower(playerName)
    
    -- Return the player's destination (or nil if not set)
    return playerDestinations[playerName]
end

-- Function to remove player destination
function Destinations.RemovePlayerDestination(playerName)
    if not playerName then
        return false
    end
    
    -- Normalize playerName to handle different formats
    playerName = string.lower(playerName)
    
    -- Check if the player has a destination
    if playerDestinations[playerName] then
        playerDestinations[playerName] = nil
        return true
    end
    
    return false
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MyAddOn.Destinations = Destinations