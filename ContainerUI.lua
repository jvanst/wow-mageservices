------------------------------------------
-- Container UI Module
------------------------------------------
local MageServices = MAGESERVICES
local Blacklist = MageServices.Blacklist

------------------------------------------
-- Create the ContainerUI module
------------------------------------------
local ContainerUI = {}

------------------------------------------
-- UI Elements
------------------------------------------

-- Create a movable container frame
ContainerUI.Frame = CreateFrame("Frame", "MageServicesContainer", UIParent)
ContainerUI.Frame:SetSize(170, 120)
ContainerUI.Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
ContainerUI.Frame:SetMovable(true)
ContainerUI.Frame:EnableMouse(true)
ContainerUI.Frame:SetClampedToScreen(true)
ContainerUI.Frame:RegisterForDrag("LeftButton")
ContainerUI.Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
ContainerUI.Frame:SetScript("OnDragStop", function(self) 
    self:StopMovingOrSizing()
    -- Save position for future sessions (optional)
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    -- You could save these values to a saved variable table here
end)

-- Add a background and border to make it visible when empty
ContainerUI.Frame.bg = ContainerUI.Frame:CreateTexture(nil, "BACKGROUND")
ContainerUI.Frame.bg:SetAllPoints()
ContainerUI.Frame.bg:SetColorTexture(0, 0, 0, 0.5)

-- Add a header/title for dragging
ContainerUI.Frame.header = ContainerUI.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ContainerUI.Frame.header:SetPoint("TOP", 0, -5)
ContainerUI.Frame.header:SetText("MageServices Actions")

------------------------------------------
-- UI Functions
------------------------------------------

-- Function to toggle container visibility
function ContainerUI.ToggleVisibility()
    if ContainerUI.Frame:IsShown() then
        ContainerUI.Frame:Hide()
    else
        ContainerUI.Frame:Show()
    end
end

-- Function to add a Kick button to the container
local function AddKickButton()
    -- Create the Kick button
    local KickButton = CreateFrame("Button", "MageServicesKickButton", ContainerUI.Frame, "UIPanelButtonTemplate")
    KickButton:SetSize(150, 30)
    KickButton:SetPoint("TOP", ContainerUI.Frame, "TOP", 0, -30)
    KickButton:SetText("Kick Player")
    KickButton:Hide()

    -- Function to handle the Kick button click
    KickButton:SetScript("OnClick", function()
        local playerName = UnitName("NPC")
        if playerName then
            Blacklist.AddPlayer(playerName)
            print("Player " .. playerName .. " has been blacklisted and kicked.")
            -- Add logic to kick the player from the group if applicable
        else
            print("No player to kick.")
        end
        KickButton:Hide()
    end)

    -- Update the ShowKickButton function to accept a player name
    function ContainerUI.ShowKickButton(playerName)
        if playerName then
            KickButton:SetText("Kick player")
            KickButton:Show()
        else
            KickButton:Hide()
        end
    end

    -- Hide the Kick button when the container is hidden
    ContainerUI.Frame:HookScript("OnHide", function()
        KickButton:Hide()
    end)
end

-- Add the Kick button to the container
AddKickButton()

------------------------------------------
-- Slash Commands
------------------------------------------

-- Create a slash command to toggle the frame
SLASH_PORTALFRAME1 = "/portalframe"
SlashCmdList["PORTALFRAME"] = function()
    ContainerUI.ToggleVisibility()
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageServices.ContainerUI = ContainerUI