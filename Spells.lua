------------------------------------------
-- Spells Module
------------------------------------------
local MageService = MAGESERVICE
local ContainerUI = MageService.ContainerUI

------------------------------------------
-- Create the Spells module
------------------------------------------
local Spells = {}

------------------------------------------
-- Portal Configuration
------------------------------------------
-- Portal spell names for Classic Era
Spells.PortalNames = {
    Stormwind = "Portal: Stormwind",
    Ironforge = "Portal: Ironforge",
    Darnassus = "Portal: Darnassus",
    -- Add other destinations as needed
}

------------------------------------------
-- UI Elements
------------------------------------------
-- Use the container frame from ContainerUI
Spells.Container = ContainerUI.Frame

-- Create a secure action button for casting inside the container
Spells.CastButton = CreateFrame("Button", "MageServiceCastButton", Spells.Container, "SecureActionButtonTemplate,UIPanelButtonTemplate")
Spells.CastButton:SetSize(150, 30)
-- Position will be handled by the ContainerUI layout system
Spells.CastButton:SetText("Cast Portal")
-- Initialize as disabled instead of hidden
Spells.CastButton:Disable()
Spells.CastButton:SetAlpha(0.5)

-- Register with ContainerUI layout system (priority 20 - second position)
ContainerUI.RegisterButton(Spells.CastButton, 20)

-- Create a timer to hide the button after 15 seconds
Spells.HideTimer = nil

------------------------------------------
-- Portal Functions
------------------------------------------
-- Function to cast a portal spell based on destination
function Spells.CastPortal(destination)
    local spellName = Spells.PortalNames[destination]
    
    if not spellName then
        print("Error: No portal spell found for destination: " .. tostring(destination))
        return false
    end
    
    -- Set up the secure button to cast the spell
    Spells.CastButton:SetAttribute("type", "spell")
    Spells.CastButton:SetAttribute("spell", spellName)
    Spells.CastButton:SetText("Cast Portal")
    
    -- Check if player is currently casting a spell
    local function ShowPortalButton()
        if UnitCastingInfo("player") then
            -- Player is casting, wait and try again in 0.5 seconds
            C_Timer.After(0.5, ShowPortalButton)
            return
        end
        
        -- Disable conjure button while portal button is enabled
        Spells.ConjureButton:Disable()
        Spells.ConjureButton:SetAlpha(0.5)
        
        -- Notify the user they need to click the button
        print("|cFF00FF00Click the button to cast " .. spellName .. "|r")
        
        -- Enable the button
        Spells.CastButton:Enable()
        Spells.CastButton:SetAlpha(1.0)
        
        -- Disable the button after 15 seconds if not clicked
        if Spells.HideTimer then
            Spells.HideTimer:Cancel()
        end
        
        Spells.HideTimer = C_Timer.NewTimer(15, function()
            Spells.CastButton:Disable()
            Spells.CastButton:SetAlpha(0.5)
            print("Portal cast button disabled due to timeout")
            -- Enable conjure button again
            Spells.UpdateConjureButton()
        end)
    end
    
    -- Start the check process
    ShowPortalButton()
    
    -- Add a handler to hide the button after it's clicked
    Spells.CastButton:SetScript("PostClick", function()
        SendChatMessage("Casting port to " .. destination .. ". Please click the portal!", "PARTY")

        if Spells.HideTimer then
            Spells.HideTimer:Cancel()
            Spells.HideTimer = nil
        end
        Spells.CastButton:Disable()
        Spells.CastButton:SetAlpha(0.5)
        
        -- Enable conjure button again
        Spells.UpdateConjureButton()
    end)
    
    return true
end

------------------------------------------
-- Food & Water Configuration
------------------------------------------
-- Conjure spell names for Classic Era
Spells.ConjureNames = {
    water = "Conjure Water",
    food = "Conjure Food"
}

------------------------------------------
-- Food & Water UI Elements
------------------------------------------
-- Create a secure action button for conjuring inside the container
Spells.ConjureButton = CreateFrame("Button", "MageServiceConjureButton", Spells.Container, "SecureActionButtonTemplate,UIPanelButtonTemplate")
Spells.ConjureButton:SetSize(150, 30)
Spells.ConjureButton:SetText("Conjure")

-- Register with ContainerUI layout system (priority 30 - third position)
ContainerUI.RegisterButton(Spells.ConjureButton, 30)

------------------------------------------
-- Food & Water Functions
------------------------------------------
-- Function to check if an item exists in bags
function Spells.HasItemInBags(itemName)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo and itemInfo.itemName == itemName then
                return true
            end
        end
    end
    return false
end

-- Function to count how many of a specific item exists in bags
function Spells.CountItemsInBags(itemName)
    local count = 0
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo and itemInfo.itemName == itemName then
                count = count + (itemInfo.stackCount or 1)
            end
        end
    end
    return count
end

-- Updated function to update conjure button based on what's needed
function Spells.UpdateConjureButton()
    -- Define thresholds
    local waterThreshold = 700
    local foodThreshold = 300
    
    -- Check if player is currently casting
    local isCasting = UnitCastingInfo("player") ~= nil
    
    -- Disable button if player is already casting
    if isCasting then
        Spells.ConjureButton:Disable()
        Spells.ConjureButton:SetAlpha(0.5)
        return
    end
    
    -- Check mana percentage
    local currentMana = UnitPower("player", Enum.PowerType.Mana)
    local maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
    local manaPercentage = (currentMana / maxMana) * 100
    
    -- Disable button if mana is below 25%
    if manaPercentage < 25 then
        Spells.ConjureButton:Disable()
        Spells.ConjureButton:SetAlpha(0.5)
        return
    end
    
    -- Count current items
    local waterCount = Spells.CountItemsInBags(MageService.Trade.Items.water)
    local foodCount = Spells.CountItemsInBags(MageService.Trade.Items.food)
    
    -- Disable button if we have enough of both
    if waterCount >= waterThreshold and foodCount >= foodThreshold then
        Spells.ConjureButton:Disable()
        Spells.ConjureButton:SetAlpha(0.5)
        return
    else
        Spells.ConjureButton:Enable()
        Spells.ConjureButton:SetAlpha(1.0)
    end
    
    -- Determine what to conjure based on what's most needed
    if waterCount < waterThreshold and (waterCount < foodThreshold or foodCount >= foodThreshold) then
        Spells.ConjureButton:SetAttribute("type", "spell")
        Spells.ConjureButton:SetAttribute("spell", Spells.ConjureNames.water)
    elseif foodCount < foodThreshold then
        Spells.ConjureButton:SetAttribute("type", "spell")
        Spells.ConjureButton:SetAttribute("spell", Spells.ConjureNames.food)
    end
end

------------------------------------------
-- UI Event Handlers
------------------------------------------
-- Set up tooltip for the button
Spells.ConjureButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Conjure Food or Water")
    GameTooltip:AddLine("Automatically selects what to conjure based on inventory", 1, 1, 1)
    GameTooltip:Show()
end)

Spells.ConjureButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Add cooldown handling for the conjure button
Spells.ConjureButton:SetScript("PostClick", function(self)
    -- Disable the button
    self:Disable()
    self:SetAlpha(0.5) -- Visual feedback that button is disabled
    
    -- Create a timer to re-enable after 3 seconds
    C_Timer.After(3.5, function()
        self:Enable()
        self:SetAlpha(1.0)
        
        -- Update the button in case resources changed during cast
        Spells.UpdateConjureButton()
    end)
end)

------------------------------------------
-- Event Registration
------------------------------------------
-- Create a frame to update the button state when bags change or mana changes
local bagUpdateFrame = CreateFrame("Frame")
bagUpdateFrame:RegisterEvent("BAG_UPDATE")
bagUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
bagUpdateFrame:RegisterEvent("UNIT_POWER_UPDATE")
bagUpdateFrame:SetScript("OnEvent", function(self, event, unit)
    -- Only update if it's the player's power that changed
    if event ~= "UNIT_POWER_UPDATE" or (event == "UNIT_POWER_UPDATE" and unit == "player") then
        Spells.UpdateConjureButton()
    end
end)

------------------------------------------
-- Initialization
------------------------------------------
-- Initialize the button
Spells.UpdateConjureButton()

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageService.Spells = Spells