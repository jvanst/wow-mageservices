local MyAddOn = MYADDON

-- Create the Trade module
local TradeFood = {}

-- Configuration for class-specific food and water distribution
-- Format: [CLASS] = { water = X, food = Y }
TradeFood.ClassConfig = {
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
TradeFood.Items = {
    water = "Conjured Crystal Water",
    food = "Conjured Sweet Roll" -- Replace with the actual conjured food name
}

-- Function to get player class
function TradeFood.GetTargetClass()
    if UnitExists("NPC") then
        local _, class = UnitClass("NPC")
        return class
    end
    return nil
end

-- Function to add items to trade window
function TradeFood.Fill()
    local targetClass = TradeFood.GetTargetClass()
    local config
    
    -- Get configuration based on class or use default
    if targetClass and TradeFood.ClassConfig[targetClass] then
        config = TradeFood.ClassConfig[targetClass]
    else
        config = TradeFood.ClassConfig["DEFAULT"]
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
                if itemName == TradeFood.Items.water and waterAdded < config.water then
                    C_Container.PickupContainerItem(bag, slot)
                    ClickTradeButton(tradeSlot)
                    waterAdded = waterAdded + 1
                    tradeSlot = tradeSlot + 1
                -- Check and add food
                elseif itemName == TradeFood.Items.food and foodAdded < config.food then
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
    
    print("TradeFood: Completed filling trade window - " .. waterAdded .. " water and " .. foodAdded .. " food added")
end

-- Register the module in the addon namespace
MyAddOn.TradeFood = TradeFood