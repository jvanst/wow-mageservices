------------------------------------------
-- Trade Timeout Monitor
------------------------------------------
-- This module monitors trade timeouts and handles the logic for blacklisting players 
-- who do not complete their trades within a specified time limit.
-- It uses the C_Timer API to create a timer that checks for trade completion.

local MageServices = MAGESERVICES
local Blacklist = MageServices.Blacklist
local Trade = MageServices.Trade

------------------------------------------
-- Create the module
------------------------------------------
local TradeTimeoutMonitor = {}

------------------------------------------
-- Configuration
------------------------------------------
-- Trade timeout configuration
local TRADE_TIMEOUT_SECONDS = 30
local tradeTimeoutTimer = nil

------------------------------------------
-- Core Functions
------------------------------------------

-- Function to start the trade timeout monitoring
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

-- Function to stop the trade timeout monitoring
function TradeTimeoutMonitor.Stop()
    if tradeTimeoutTimer then
        tradeTimeoutTimer:Cancel()
        tradeTimeoutTimer = nil
    end
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageServices.TradeTimeoutMonitor = TradeTimeoutMonitor

