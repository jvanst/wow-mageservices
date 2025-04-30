local MyAddOn = MYADDON
local Destinations = MyAddOn.Destinations
local TradeFood = MyAddOn.TradeFood
local Utils = MyAddOn.Utils

-- Create the Trade module
local TradePortal = {}

-- Required amount in copper (1 gold = 10000 copper)
local REQUIRED_GOLD_AMOUNT = 10000

-- Function to verify trade money and cast portal
function TradePortal.VerifyPortalPurchase(player)
    -- Get the amount of money the target is offering
    local targetMoney = GetTargetTradeMoney()
        
    -- Verify the trade amount
    if targetMoney >= REQUIRED_GOLD_AMOUNT then
        return true
    end
end

-- This table will store player purchase status
local portalPurchaseStatus = {}

TradePortal.PURCHASE_STATUS = {
    PENDING_TRADE = "pending_trade",
    PENDING = "pending_payment",
    PAID = "paid",
}

function TradePortal.GetPlayerPortalPurchaseStatus(playerName)
    -- Normalize playerName to handle different formats
    playerName = string.lower(playerName)
    
    -- Return the player's purchase status (or nil if not set)
    return portalPurchaseStatus[playerName]
end

function TradePortal.SetPlayerPortalPurchaseStatus(playerName, status)
    -- Normalize playerName to handle different formats
    playerName = string.lower(playerName)
    
    -- Set the player's purchase status
    portalPurchaseStatus[playerName] = status
end

-- Function to display a summary of the trade
function TradePortal.ShowTradeSummary(player)
    -- Get traded items from player to target
    local givenItems = {}
    local waterCount = 0
    local foodCount = 0
    
    -- Check each trade slot (1-7 are item slots)
    for i = 1, 7 do
        local name, texture, quantity, quality, isUsable, enchantment = GetTradePlayerItemInfo(i)
        if name then
            if name == TradeFood.Items.water then
                waterCount = waterCount + (quantity or 1)
            elseif name == TradeFood.Items.food then
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
    
    -- Print summary
    print("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t |cFF33FF99Trade Summary with|r |cFFFFFF00" .. player .. "|r:")
    
    if #givenItems > 0 then
        print("  |cFF00FF00Items given:|r")
        for _, item in ipairs(givenItems) do
            print("    - " .. item.quantity .. "x " .. item.name)
        end
    end
    
    if goldReceived > 0 then
        print("  |cFFFFD700Received:|r " .. goldString)
    end
    
    if waterCount > 0 or foodCount > 0 then
        local tradeType = "water/food"
        print("|cFF33FF99Trade completed:|r " .. waterCount .. " water and " .. foodCount .. " food traded to " .. player)
    elseif goldReceived >= REQUIRED_GOLD_AMOUNT then
        local destination = Destinations.GetPlayerDestination(Utils.StripRealm(player))
        if destination then
            print("|cFF33FF99Portal sale:|r " .. goldString .. " received for portal to " .. destination)
        else
            print("|cFF33FF99Trade completed:|r " .. goldString .. " received")
        end
    else
        print("|cFF33FF99Trade completed with|r " .. player)
    end
end

-- Register the module in the addon namespace
MyAddOn.TradePortal = TradePortal