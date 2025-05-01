------------------------------------------
-- Blacklist Module
------------------------------------------
local MyAddOn = MYADDON
local ContainerUI = MyAddOn.ContainerUI

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
-- UI Elements
------------------------------------------
-- Use the container frame from ContainerUI
Blacklist.Container = ContainerUI.Frame

-- Create a secure action button for casting inside the container
Blacklist.KickButton = CreateFrame("Button", "MyAddOnPortalButton", Blacklist.Container, "SecureActionButtonTemplate,UIPanelButtonTemplate")
Blacklist.KickButton:SetSize(150, 30)
Blacklist.KickButton:SetPoint("BOTTOM", Blacklist.Container, "BOTTOM", 0, 10)
Blacklist.KickButton:SetText("Kick Player")
Blacklist.KickButton:Hide()

-- Create a timer to hide the button after 15 seconds
Blacklist.HideTimer = nil

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

    Blacklist.KickButton:SetScript("OnClick", function()
        UninviteUnit(playerName)
    end)

    -- Show the button
    Blacklist.KickButton:Show()

    -- Hide the button after 15 seconds if not clicked
    if Blacklist.HideTimer then
        Blacklist.HideTimer:Cancel()
    end
    
    Blacklist.HideTimer = C_Timer.NewTimer(15, function()
        Blacklist.KickButton:Hide()
        print("Portal cast button hidden due to timeout")
    end)
    
    -- Add a handler to hide the button after it's clicked
    Blacklist.KickButton:SetScript("PostClick", function()
        if Blacklist.HideTimer then
            Blacklist.HideTimer:Cancel()
            Blacklist.HideTimer = nil
        end
        Blacklist.KickButton:Hide()
    end)
end

-- Function to remove a player from the blacklist
function Blacklist.RemovePlayer(playerName)
    blacklistedPlayers[playerName] = nil
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MyAddOn.Blacklist = Blacklist