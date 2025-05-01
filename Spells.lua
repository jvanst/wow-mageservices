------------------------------------------
-- Spells Module
------------------------------------------
local MyAddOn = MYADDON
local ContainerUI = MyAddOn.ContainerUI

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
Spells.CastButton = CreateFrame("Button", "MyAddOnPortalButton", Spells.Container, "SecureActionButtonTemplate,UIPanelButtonTemplate")
Spells.CastButton:SetSize(150, 30)
Spells.CastButton:SetPoint("BOTTOM", Spells.Container, "BOTTOM", 0, 10)
Spells.CastButton:Hide()

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
        
        -- Hide conjure buttons while portal button is visible
        Spells.ConjureButton:Hide()
        
        -- Notify the user they need to click the button
        print("|cFF00FF00Click the button to cast " .. spellName .. "|r")
        
        -- Show the button
        Spells.CastButton:Show()
        
        -- Hide the button after 15 seconds if not clicked
        if Spells.HideTimer then
            Spells.HideTimer:Cancel()
        end
        
        Spells.HideTimer = C_Timer.NewTimer(15, function()
            Spells.CastButton:Hide()
            print("Portal cast button hidden due to timeout")
            -- Show conjure buttons again
            Spells.UpdateConjureButton()
        end)
    end
    
    -- Start the check process
    ShowPortalButton()
    
    -- Add a handler to hide the button after it's clicked
    Spells.CastButton:SetScript("PostClick", function()
        if Spells.HideTimer then
            Spells.HideTimer:Cancel()
            Spells.HideTimer = nil
        end
        Spells.CastButton:Hide()
        
        -- Show conjure buttons again
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
Spells.ConjureButton = CreateFrame("Button", "MyAddOnConjureButton", Spells.Container, "SecureActionButtonTemplate,UIPanelButtonTemplate")
Spells.ConjureButton:SetSize(150, 30)
Spells.ConjureButton:SetPoint("BOTTOM", Spells.Container, "BOTTOM", 0, 45) -- Position above the portal button
Spells.ConjureButton:SetText("Conjure Food/Water")

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
    
    -- Check mana percentage
    local currentMana = UnitPower("player", Enum.PowerType.Mana)
    local maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
    local manaPercentage = (currentMana / maxMana) * 100
    
    -- Hide button if mana is below 25%
    if manaPercentage < 25 then
        Spells.ConjureButton:Hide()
        return
    end
    
    -- Count current items
    local waterCount = Spells.CountItemsInBags(MyAddOn.Trade.Items.water)
    local foodCount = Spells.CountItemsInBags(MyAddOn.Trade.Items.food)
    
    -- Hide button if we have enough of both
    if waterCount >= waterThreshold and foodCount >= foodThreshold then
        Spells.ConjureButton:Hide()
        return
    else
        Spells.ConjureButton:Show()
    end
    
    -- Determine what to conjure based on what's most needed
    if waterCount < waterThreshold and (waterCount < foodThreshold or foodCount >= foodThreshold) then
        Spells.ConjureButton:SetAttribute("type", "spell")
        Spells.ConjureButton:SetAttribute("spell", Spells.ConjureNames.water)
        Spells.ConjureButton:SetText("Conjure Water")
    elseif foodCount < foodThreshold then
        Spells.ConjureButton:SetAttribute("type", "spell")
        Spells.ConjureButton:SetAttribute("spell", Spells.ConjureNames.food)
        Spells.ConjureButton:SetText("Conjure Food")
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
MyAddOn.Spells = Spells