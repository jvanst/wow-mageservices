------------------------------------------
-- Utilities Module
------------------------------------------
local MageServices = MAGESERVICES

------------------------------------------
-- Create the Utils module
------------------------------------------
local Utils = {}

------------------------------------------
-- Utility Functions
------------------------------------------

-- Function to strip realm name from player name
function Utils.StripRealm(playerName)
    if not playerName then return nil end
    local name = string.match(playerName, "^([^-]+)")
    return name or playerName
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageServices.Utils = Utils