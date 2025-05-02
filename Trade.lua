local MageService = MAGESERVICE
local Destinations = MageService.Destinations
local Utils = MageService.Utils

------------------------------------------
-- Create the Trade module
------------------------------------------
local Trade = {}

------------------------------------------
-- Food & Water Configuration
------------------------------------------

-- Configuration for class-specific food and water distribution
-- Format: [CLASS] = { water = X, food = Y }
Trade.ClassConfig = {
    ["WARRIOR"] = { water = 1, food = 4 },
    ["PALADIN"] = { water = 5, food = 1 },
    ["HUNTER"] = { water = 4, food = 2 },
    ["ROGUE"] = { water = 1, food = 4 },
    ["PRIEST"] = { water = 5, food = 1 },
    ["SHAMAN"] = { water = 5, food = 1 },
    ["MAGE"] = { water = 3, food = 3 }, -- Mages can create their own
    ["WARLOCK"] = { water = 3, food = 3 },
    ["DRUID"] = { water = 4, food = 2 },
    -- Default for unknown classes
    ["DEFAULT"] = { water = 2, food = 2 }
}

-- Item names for food and water
Trade.Items = {
    water = "Conjured Crystal Water",
    food = "Conjured Sweet Roll" -- Replace with the actual conjured food name
}

------------------------------------------
-- Portal Configuration
------------------------------------------

-- Required amount in copper (1 gold = 10000 copper)
local REQUIRED_GOLD_AMOUNT = 10000

-- This table will store player purchase status
local portalPurchaseStatus = {}

-- Portal purchase status constants
Trade.PURCHASE_STATUS = {
    PENDING_TRADE = "pending_trade",
    PENDING = "pending_payment",
    PAID = "paid",
}

------------------------------------------
-- Common Trade Functions
------------------------------------------

-- Function to get target player class
function Trade.GetTargetClass()
    if UnitExists("NPC") then
        local _, class = UnitClass("NPC")
        return class
    end
    return nil
end

------------------------------------------
-- Food & Water Functions
------------------------------------------

-- Function to add items to trade window
function Trade.FillFoodWater()
    local targetPlayer = UnitName("NPC")
    local targetLevel = UnitLevel("NPC")
    local targetClass = Trade.GetTargetClass()
    local config
    
    -- Check if player meets minimum level requirement
    if targetLevel < 55 then
        -- Close trade window
        CancelTrade()
        -- Inform player
        SendChatMessage("Sorry, i'm only handing out level 55 food & water. You can't use it yet", "WHISPER", nil, targetPlayer)
        print("|cFFFF0000Trade cancelled:|r " .. targetPlayer .. " is only level " .. targetLevel .. " (minimum level: 55)")
        return
    end
    
    -- Get configuration based on class or use default
    if targetClass and Trade.ClassConfig[targetClass] then
        config = Trade.ClassConfig[targetClass]
    else
        config = Trade.ClassConfig["DEFAULT"]
        targetClass = "Unknown"
    end
    
    -- Find the items in the player's bags
    local waterAdded = 0
    local foodAdded = 0
    local tradeSlot = 1
    
    -- Loop through all bags
    for bag = 0, NUM_BAG_SLOTS do
        -- Get number of slots in this bag
        local numSlots = C_Container.GetContainerNumSlots(bag)
        
        -- Loop through all slots in the bag
        for slot = 1, numSlots do
            -- Skip if we've added all required items
            if waterAdded >= config.water and foodAdded >= config.food then
                break
            end
            
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo then
                local itemName = itemInfo.itemName
                
                -- Check and add water
                if itemName == Trade.Items.water and waterAdded < config.water then
                    C_Container.PickupContainerItem(bag, slot)
                    ClickTradeButton(tradeSlot)
                    waterAdded = waterAdded + 1
                    tradeSlot = tradeSlot + 1
                -- Check and add food
                elseif itemName == Trade.Items.food and foodAdded < config.food then
                    C_Container.PickupContainerItem(bag, slot)
                    ClickTradeButton(tradeSlot)
                    foodAdded = foodAdded + 1
                    tradeSlot = tradeSlot + 1
                end
            end
        end
    end
    
    -- Show warnings only if we couldn't add all requested items
    if waterAdded < config.water then
        print("Warning: Could only add " .. waterAdded .. " of " .. config.water .. " water stacks")
    end
    
    if foodAdded < config.food then
        print("Warning: Could only add " .. foodAdded .. " of " .. config.food .. " food stacks")
    end
    
    print("Trade: Completed filling trade window - " .. waterAdded .. " water and " .. foodAdded .. " food added")
end

------------------------------------------
-- Portal Functions
------------------------------------------

-- Function to verify trade money and cast portal
function Trade.VerifyPortalPurchase(player)
    -- Get the amount of money the target is offering
    local targetMoney = GetTargetTradeMoney()
        
    -- Verify the trade amount
    if targetMoney >= REQUIRED_GOLD_AMOUNT then
        return true
    end
end

-- Function to get player portal purchase status
function Trade.GetPlayerPortalPurchaseStatus(playerName)
    -- Normalize playerName to handle different formats
    playerName = string.lower(playerName)
    
    -- Return the player's purchase status (or nil if not set)
    return portalPurchaseStatus[playerName]
end

-- Function to set player portal purchase status
function Trade.SetPlayerPortalPurchaseStatus(playerName, status)
    -- Normalize playerName to handle different formats
    playerName = string.lower(playerName)
    
    -- Set the player's purchase status
    portalPurchaseStatus[playerName] = status
end

-- Function to display a summary of the trade
function Trade.PrintTradeSummary(player)
    -- Get traded items from player to target
    local givenItems = {}
    local waterCount = 0
    local foodCount = 0
    
    -- Check each trade slot (1-7 are item slots)
    for i = 1, 7 do
        local name, texture, quantity, quality, isUsable, enchantment = GetTradePlayerItemInfo(i)
        if name then
            if name == Trade.Items.water then
                waterCount = waterCount + (quantity or 1)
            elseif name == Trade.Items.food then
                foodCount = foodCount + (quantity or 1)
            end
            
            table.insert(givenItems, {name = name, quantity = quantity or 1})
        end
    end
    
    -- Get gold amount from target
    local goldReceived = GetTargetTradeMoney()
    local gold = math.floor(goldReceived / 10000)
    local silver = math.floor((goldReceived % 10000) / 100)
    local copper = goldReceived % 100
    
    -- Format gold string
    local goldString = ""
    if gold > 0 then
        goldString = gold .. "g "
    end
    if silver > 0 or gold > 0 then
        goldString = goldString .. silver .. "s "
    end
    goldString = goldString .. copper .. "c"

    if Trade.GetPlayerPortalPurchaseStatus(player) == nil then
        print("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t |cFF33FF99Food & Water sale" .. ":|r " .. goldString .. " received for " .. waterCount .. " water and " .. foodCount .. " food")
    else
        print("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t |cFF33FF99Portal sale:|r " .. goldString .. " received for port")
    end
end

-- Function to create and show the accept trade button
function Trade.CreateAcceptTradeButton()
    if Trade.AcceptTradeButton then
        Trade.AcceptTradeButton:Show()
        return
    end
    
    -- Get the container from ContainerUI
    local container = MageService.ContainerUI.Frame
    
    -- Create the AcceptTrade button
    Trade.AcceptTradeButton = CreateFrame("Button", "MageServiceAcceptTradeButton", container, "UIPanelButtonTemplate")
    Trade.AcceptTradeButton:SetSize(150, 30)
    -- Position will be handled by ContainerUI system
    Trade.AcceptTradeButton:SetText("Accept Trade")
    
    -- Function to handle the AcceptTrade button click
    Trade.AcceptTradeButton:SetScript("OnClick", function()
        AcceptTrade()
        print("|cFF33FF99Trade:|r Accepting trade...")
        -- Hide the button after accepting
        Trade.ToggleAcceptTradeButton(false)
    end)
    
    -- Add tooltip
    Trade.AcceptTradeButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Accept Trade")
        GameTooltip:AddLine("Click to accept the current trade", 1, 1, 1)
        GameTooltip:Show()
    end)
    
    Trade.AcceptTradeButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Register with ContainerUI layout system (priority 10 - top position)
    MageService.ContainerUI.RegisterButton(Trade.AcceptTradeButton, 10)
    
    -- Hide the button initially until trade window is shown
    Trade.AcceptTradeButton:Hide()
end

-- Function to show/hide accept trade button
function Trade.ToggleAcceptTradeButton(show)
    if not Trade.AcceptTradeButton then
        if show then
            Trade.CreateAcceptTradeButton()
        end
        return
    end
    
    -- Always show the button, but enable/disable based on parameter
    Trade.AcceptTradeButton:Show()
    
    if show then
        Trade.AcceptTradeButton:Enable()
        Trade.AcceptTradeButton:SetAlpha(1.0)
    else
        Trade.AcceptTradeButton:Disable()
        Trade.AcceptTradeButton:SetAlpha(0.5) -- Visual indicator that button is disabled
    end
end

Trade.CreateAcceptTradeButton()
Trade.ToggleAcceptTradeButton(false)

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageService.Trade = Trade