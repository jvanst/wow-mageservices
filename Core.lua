------------------------------------------
-- Core Module
------------------------------------------
local MageService = MAGESERVICE
local Destinations = MageService.Destinations
local Blacklist = MageService.Blacklist
local Utils = MageService.Utils
local Trade = MageService.Trade
local TradeProximityMonitor = MageService.TradeProximityMonitor
local TradeTimeoutMonitor = MageService.TradeTimeoutMonitor
local Spells = MageService.Spells

------------------------------------------
-- Addon Configuration
------------------------------------------
local addonEnabled = true -- Default to enabled

local frame = CreateFrame("Frame")

------------------------------------------
-- Event Registration
------------------------------------------
-- Register events for most chat message types
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_WHISPER")

-- Register the ADDON_LOADED event to print an initialization message
frame:RegisterEvent("ADDON_LOADED")

-- Add event handler for party changes
frame:RegisterEvent("GROUP_ROSTER_UPDATE")

------------------------------------------
-- Trade Event Registration
------------------------------------------
frame:RegisterEvent("TRADE_SHOW")
frame:RegisterEvent("TRADE_CLOSED")
frame:RegisterEvent("TRADE_REQUEST_CANCEL")
frame:RegisterEvent("TRADE_ACCEPT_UPDATE")

-- Add event handler for trade money update
frame:RegisterEvent("TRADE_MONEY_CHANGED")
frame:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED")
frame:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")

-- Register trade request events to handle timeouts
frame:RegisterEvent("TRADE_SHOW")
frame:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")

------------------------------------------
-- Slash Command Handling
------------------------------------------
local function SlashCommandHandler(msg)
    msg = string.lower(msg or "")
    
    if msg == "on" then
        addonEnabled = true
        print("|cFF33FF99MageService:|r |cFF00FF00Enabled|r")
    elseif msg == "off" then
        addonEnabled = false
        print("|cFF33FF99MageService:|r |cFFFF0000Disabled|r")
    else
        -- Toggle if no specific command
        addonEnabled = not addonEnabled
        if addonEnabled then
            print("|cFF33FF99MageService:|r |cFF00FF00Enabled|r")
        else
            print("|cFF33FF99MageService:|r |cFFFF0000Disabled|r")
        end
    end
end

-- Register slash commands
SLASH_MAGESERVICE1 = "/mageservices"
SLASH_MAGESERVICE2 = "/ms"
SlashCmdList["MAGESERVICE"] = SlashCommandHandler

------------------------------------------
-- Message Handling Functions
------------------------------------------
local function HandleMessage(message, playerName)
    local lowerMessage = string.lower(message)
    local isLookingForPort = (string.find(lowerMessage, "wtb") or string.find(lowerMessage, "lf")) and
                            (string.find(lowerMessage, "port") or string.find(lowerMessage, "portal"))

    local isLookingForWaterOrFood = (string.find(lowerMessage, "wtb") or string.find(lowerMessage, "lf")) and
                                    (string.find(lowerMessage, "water") or string.find(lowerMessage, "food"))

    if isLookingForPort then
        local foundDestination = Destinations.FindInMessage(message)

        if foundDestination then
            print("Found player " .. playerName .. " looking for portal to " .. foundDestination)
            Destinations.AddPlayerDestination(Utils.StripRealm(playerName), foundDestination)
            Trade.SetPlayerPortalPurchaseStatus(Utils.StripRealm(playerName), Trade.PURCHASE_STATUS.PENDING_TRADE)

            InviteUnit(playerName)
            SendChatMessage("Im selling ports to " .. foundDestination .. " for 1g at SW Fountain.", "WHISPER", nil, playerName)
        end
    elseif isLookingForWaterOrFood then
        SendChatMessage("I'm trading mage water and food at SW Fountain", "WHISPER", nil, playerName)
    end
end

------------------------------------------
-- Event Handler
------------------------------------------
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MageService" then
            print("|cFF33FF99MageService|r has been loaded successfully! Type |cFFFFFF00/mageservices|r or |cFFFFFF00/ms|r to toggle.")
        end
        return -- Always process ADDON_LOADED regardless of enabled state
    end
    
    -- Skip other event processing if addon is disabled
    if not addonEnabled and event ~= "ADDON_LOADED" then 
        return 
    end
    
    ------------------------------------------
    -- Chat Message Events
    ------------------------------------------
    if event == "CHAT_MSG_CHANNEL" then
        local message, playerName, _, _, _, _, _, channelIndex = ...
        
        -- Only process messages from channel /1
        if channelIndex == 1 then
            HandleMessage(message, playerName)
        end

    elseif event == "CHAT_MSG_SAY" then
        local message, playerName = ...
        HandleMessage(message, playerName)
        
    elseif event == "CHAT_MSG_YELL" then
        local message, playerName = ...
        HandleMessage(message, playerName)

    elseif event == "CHAT_MSG_WHISPER" then
        local message, playerName = ...
 
        if string.lower(message) == "inv" then
            InviteUnit(playerName)
            -- Ask the player where they'd like to port to
            SendChatMessage("Where would you like to port to?", "WHISPER", nil, playerName)
        else
            -- Check if this is a response to our destination question
            local lowerMessage = string.lower(message)
            local foundDestination = Destinations.FindInMessage(message)
            
            if foundDestination then
                print("Player " .. playerName .. " wants to port to " .. foundDestination)
                Destinations.AddPlayerDestination(Utils.StripRealm(playerName), foundDestination)
                Trade.SetPlayerPortalPurchaseStatus(Utils.StripRealm(playerName), Trade.PURCHASE_STATUS.PENDING_TRADE)
                
                -- If they're not already in the group, invite them
                if not UnitInParty(playerName) then
                    InviteUnit(playerName)
                end
            else
                -- Handle other messages as before
                HandleMessage(message, playerName)
            end
        end

    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Set raid icon (star) on yourself
        SetRaidTarget("player", 1)
        
        -- Start monitor trade proximity
        TradeProximityMonitor.Start()

    ------------------------------------------
    -- Trade Events
    ------------------------------------------
    elseif event == "TRADE_SHOW" then
        if not TradeFrame:IsVisible() then
            CancelTrade()
            return
        else
            local player = UnitName("NPC")

            -- Check if the player is blacklisted
            if not Blacklist.CheckPlayer(player) then
                print("Trade with " .. player .. " is blacklisted.")
                CancelTrade()
                return -- Trade was cancelled due to blacklisting
            end

            print("Trade with " .. player .. " initiated. Please wait for the trade to be accepted.")

            TradeTimeoutMonitor.Start(player)
    
            -- If player is not buying a port
            if Trade.GetPlayerPortalPurchaseStatus(player) == nil then
                Trade.FillFoodWater()
            end
        end

    elseif event == "TRADE_REQUEST_CANCEL" or event == "TRADE_CLOSED" then
        Trade.ToggleAcceptTradeButton(false)
        TradeTimeoutMonitor.Stop()

    elseif event == "TRADE_ACCEPT_UPDATE" then
        local playerAccepted, targetAccepted = ...
        local player = UnitName("NPC")

        if Trade.GetPlayerPortalPurchaseStatus(player) == nil then
            -- Not buying a portal
            if playerAccepted == 0 then
                C_Timer.After(1, function()
                    Trade.ToggleAcceptTradeButton(true)
                end)
            end
        else
            -- Buying portal
            if targetAccepted == 1 and playerAccepted == 0 and Trade.VerifyPortalPurchase(player) then
                -- If the other player has accepted with the correct amount of gold
                Trade.ToggleAcceptTradeButton(true)
            -- Both players have accepted
            elseif playerAccepted == 1 and targetAccepted == 1 then       
                -- When both players have accepted the trade     
                TradeTimeoutMonitor.Stop()
    
                Trade.SetPlayerPortalPurchaseStatus(Utils.StripRealm(player), Trade.PURCHASE_STATUS.PAID)
                
                Trade.PrintTradeSummary(player)
                
                -- Cast the portal spell
                local destination = Destinations.GetPlayerDestination(Utils.StripRealm(player))

                if destination == nil then
                    print("|cFFFF0000Error:|r No destination set for player " .. player)
                    return
                end

                Spells.CastPortal(destination)
            end
        end
    end
end)
