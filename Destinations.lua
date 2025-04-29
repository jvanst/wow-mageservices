local MyAddOn = MYADDON

-- Create the Destinations module
local Destinations = {}

-- This table will store the destination keywords
-- The keys are the destination names, and the values are lists of keywords
-- that can be used to identify them in messages
local destinationMap = {
    Stormwind = {"sw", "stormw", "stormwind", "storm wind"},
    Ironforge = {"if", "ironforge", "ironf"},
    Darnassus = {"darn", "darnassus", "darnas"},
}

-- A function to find a destination in a message
-- This function will check if the message contains any of the destination keywords
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

-- This table will store player destinations
-- The keys will be player names (normalized), and the values will be destination names
local playerDestinations = {}

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

function Destinations.GetPlayerDestination(playerName)
    -- Print all player destinations for debugging
    for name, dest in pairs(playerDestinations) do
        print("Player: " .. name .. ", Destination: " .. dest)
    end

    if not playerName then
        return nil
    end
    
    -- Normalize playerName to handle different formats
    playerName = string.lower(playerName)
    
    -- Return the player's destination (or nil if not set)
    return playerDestinations[playerName]
end

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

-- Register the module in the addon namespace
MyAddOn.Destinations = Destinations