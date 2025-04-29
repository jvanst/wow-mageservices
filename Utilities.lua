local MyAddOn = MYADDON

-- Create the Utils module
local Utils = {}

-- Define utility functions
function Utils.StripRealm(playerName)
    if not playerName then return nil end
    local name = string.match(playerName, "^([^-]+)")
    return name or playerName
end

-- Register the module in the addon namespace
MyAddOn.Utils = Utils