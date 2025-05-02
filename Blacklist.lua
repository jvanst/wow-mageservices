------------------------------------------
-- Blacklist Module
------------------------------------------
local MageService = MAGESERVICE
local ContainerUI = MageService.ContainerUI

------------------------------------------
-- Create the Blacklist module
------------------------------------------
local Blacklist = {}

------------------------------------------
-- Blacklist Data
------------------------------------------
-- Table to store blacklisted players
local blacklistedPlayers = {}

------------------------------------------
-- Blacklist Functions
------------------------------------------

-- Function to handle trade requests and check if player is blacklisted
function Blacklist.CheckPlayer(playerName)
    if blacklistedPlayers[playerName] then
        return false
    end
    return true
end

-- Function to add a player to the blacklist
function Blacklist.AddPlayer(playerName)
    blacklistedPlayers[playerName] = true
end

-- Function to remove a player from the blacklist
function Blacklist.RemovePlayer(playerName)
    blacklistedPlayers[playerName] = nil
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageService.Blacklist = Blacklist