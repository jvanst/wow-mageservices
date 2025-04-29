local MyAddOn = MYADDON

-- Create the Trade module
local TradeFood = {}

-- Configuration for class-specific food and water distribution
-- Format: [CLASS] = { water = X, food = Y }
TradeFood.ClassConfig = {
    ["WARRIOR"] = { water = 1, food = 3 },
    ["PALADIN"] = { water = 3, food = 3 },
    ["HUNTER"] = { water = 4, food = 2 },
    ["ROGUE"] = { water = 1, food = 4 },
    ["PRIEST"] = { water = 4, food = 1 },
    ["SHAMAN"] = { water = 4, food = 1 },
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
    print("TradeFood: Starting to fill trade window...")
    local targetClass = TradeFood.GetTargetClass()
    local config
    
    -- Get configuration based on class or use default
    if targetClass and TradeFood.ClassConfig[targetClass] then
        config = TradeFood.ClassConfig[targetClass]
        print("Trading with " .. targetClass .. ": " .. config.water .. " water, " .. config.food .. " food")
    else
        config = TradeFood.ClassConfig["DEFAULT"]
        print("Trading with unknown class: " .. config.water .. " water, " .. config.food .. " food")
    end
    
    -- Find the items in the player's bags
    -- Ensure to select stacks of 20, and not to select the same item stack twice
    local waterAdded = 0
    local foodAdded = 0
    local tradeSlot = 1
    
    print("TradeFood: Scanning bags for " .. TradeFood.Items.water .. " and " .. TradeFood.Items.food)
    
    -- Loop through all bags
    for bag = 0, NUM_BAG_SLOTS do
        -- Get number of slots in this bag
        local numSlots = C_Container.GetContainerNumSlots(bag)
        print("TradeFood: Checking bag " .. bag .. " with " .. numSlots .. " slots")
        
        -- Loop through all slots in the bag
        for slot = 1, numSlots do
            -- Skip if we've added all required items
            if waterAdded >= config.water and foodAdded >= config.food then
                print("TradeFood: All items added, breaking out of bag scan")
                break
            end
            
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo then
                local itemName = itemInfo.itemName
                
                -- Check and add water
                if itemName == TradeFood.Items.water and waterAdded < config.water then
                    print("TradeFood: Found water in bag " .. bag .. ", slot " .. slot)
                    C_Container.PickupContainerItem(bag, slot)
                    ClickTradeButton(tradeSlot)
                    waterAdded = waterAdded + 1
                    tradeSlot = tradeSlot + 1
                    print("TradeFood: Added water to trade slot " .. (tradeSlot - 1) .. " (" .. waterAdded .. "/" .. config.water .. ")")
                -- Check and add food
                elseif itemName == TradeFood.Items.food and foodAdded < config.food then
                    print("TradeFood: Found food in bag " .. bag .. ", slot " .. slot)
                    C_Container.PickupContainerItem(bag, slot)
                    ClickTradeButton(tradeSlot)
                    foodAdded = foodAdded + 1
                    tradeSlot = tradeSlot + 1
                    print("TradeFood: Added food to trade slot " .. (tradeSlot - 1) .. " (" .. foodAdded .. "/" .. config.food .. ")")
                end
            end
        end
    end
    
    -- Inform the user if we couldn't add all requested items
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