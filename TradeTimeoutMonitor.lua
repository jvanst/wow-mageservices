-- This module monitors trade timeouts and handles the logic for blacklisting players who do not complete their trades within a specified time limit.
-- It uses the C_Timer API to create a timer that checks for trade completion every 30 seconds.

local MyAddOn = MYADDON
local Blacklist = MyAddOn.Blacklist
local Trade = MyAddOn.Trade

-- Create the Utils module
local TradeTimeoutMonitor = {}

-- Trade timeout configuration
local TRADE_TIMEOUT_SECONDS = 30
local tradeTimeoutTimer = nil

function TradeTimeoutMonitor.Start(player)
    -- Start the trade timeout timer
    if tradeTimeoutTimer then
        tradeTimeoutTimer:Cancel()
    end

    tradeTimeoutTimer = C_Timer.NewTimer(TRADE_TIMEOUT_SECONDS, function()
        print("Trade with " .. player .. " timed out.")

        -- Reset the trade status and blacklist the player
        Trade.SetPlayerPortalPurchaseStatus(player, nil)
        Blacklist.AddPlayer(player)

        -- Cancel the trade and notify the player
        CancelTrade()
    end)
end

function TradeTimeoutMonitor.Stop()
    if tradeTimeoutTimer then
        tradeTimeoutTimer:Cancel()
        tradeTimeoutTimer = nil
    end
end

-- Register the module in the addon namespace
MyAddOn.TradeTimeoutMonitor = TradeTimeoutMonitor

