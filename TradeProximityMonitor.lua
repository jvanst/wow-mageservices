------------------------------------------
-- Trade Proximity Monitor
------------------------------------------
-- This module monitors the proximity of players in a group and initiates trade if they are within range.
-- It uses the C_Timer API to create a ticker that checks for players in trade range every 2 seconds.

local MageService = MAGESERVICE
local Trade = MageService.Trade

------------------------------------------
-- Create the module
------------------------------------------
local TradeProximityMonitor = {}

-- Add a variable to track the active ticker
local proximityTicker = nil

------------------------------------------
-- Functions
------------------------------------------

-- Function to start monitoring players in proximity
function TradeProximityMonitor.Start()
    print("Starting Trade Proximity Monitor...")

    -- Cancel existing ticker if it exists
    if proximityTicker then
        proximityTicker:Cancel()
    end
    
    -- Create a new ticker to check for players in trade range every 2 seconds
    proximityTicker = C_Timer.NewTicker(1.5, function()
        local partySize = GetNumGroupMembers()

        if partySize <= 1 then
            print("Stopping Trade Proximity Monitor...")
            -- If not in a group, cancel the ticker
            proximityTicker:Cancel()
        end

        if TradeFrame and TradeFrame:IsShown() then
            -- If the trade window is open, don't check for proximity
            return
        end

        for i = 1, partySize do
            local unit = "party" .. i
            if UnitExists(unit) then
                local unitName = UnitName(unit)
                -- Check if the unit is in trade range and has a pending purchase status
                if Trade.GetPlayerPortalPurchaseStatus(unitName) == Trade.PURCHASE_STATUS.PENDING_TRADE then                    
                    if CheckInteractDistance(unit, 2) then
                        print("Player " .. unitName .. " is in trade range, initiating trade.")
                        InitiateTrade(unit)
                        -- Set the player's purchase status to pending payment
                        Trade.SetPlayerPortalPurchaseStatus(unitName, Trade.PURCHASE_STATUS.PENDING)
                        break
                    end
                end
            end
        end
    end, 0) -- Zero repeat count means it runs until manually canceled
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageService.TradeProximityMonitor = TradeProximityMonitor
