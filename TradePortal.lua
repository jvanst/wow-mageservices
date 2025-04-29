local MyAddOn = MYADDON

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

-- Register the module in the addon namespace
MyAddOn.TradePortal = TradePortal