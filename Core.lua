-- Reference the namespace and modules
local MyAddOn = MYADDON
local Destinations = MyAddOn.Destinations
local Blacklist = MyAddOn.Blacklist
local Utils = MyAddOn.Utils
local TradePortal = MyAddOn.TradePortal
local TradeFood = MyAddOn.TradeFood
local TradeProximityMonitor = MyAddOn.TradeProximityMonitor
local TradeTimeoutMonitor = MyAddOn.TradeTimeoutMonitor
local Spells = MyAddOn.Spells

-- Add enabled state variable
local addonEnabled = true -- Default to enabled

local frame = CreateFrame("Frame")

-- Register events for most chat message types
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
frame:RegisterEvent("CHAT_MSG_WHISPER")

-- Register the ADDON_LOADED event to print an initialization message
frame:RegisterEvent("ADDON_LOADED")

-- Add event handler for party changes
frame:RegisterEvent("GROUP_ROSTER_UPDATE")

-- Add event handler for trade events
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

-- Slash command handler function
local function SlashCommandHandler(msg)
    msg = string.lower(msg or "")
    
    if msg == "on" then
        addonEnabled = true
        print("|cFF33FF99MyAddOn:|r |cFF00FF00Enabled|r - Now monitoring for portal requests")
    elseif msg == "off" then
        addonEnabled = false
        print("|cFF33FF99MyAddOn:|r |cFFFF0000Disabled|r - No longer monitoring for portal requests")
    else
        -- Toggle if no specific command
        addonEnabled = not addonEnabled
        if addonEnabled then
            print("|cFF33FF99MyAddOn:|r |cFF00FF00Enabled|r - Now monitoring for portal requests")
        else
            print("|cFF33FF99MyAddOn:|r |cFFFF0000Disabled|r - No longer monitoring for portal requests")
        end
    end
end

-- Register slash commands
SLASH_MYADDON1 = "/myaddon"
SLASH_MYADDON2 = "/ma"
SlashCmdList["MYADDON"] = SlashCommandHandler

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
            TradePortal.SetPlayerPortalPurchaseStatus(Utils.StripRealm(playerName), TradePortal.PURCHASE_STATUS.PENDING_TRADE)

            InviteUnit(playerName)
            SendChatMessage("Im selling ports to " .. foundDestination .. " for 1g at SW Fountain.", "WHISPER", nil, playerName)
        end
    elseif isLookingForWaterOrFood then
        SendChatMessage("I'm trading mage water and food at SW Fountain", "WHISPER", nil, playerName)
    end
end

-- Function to display a summary of the trade
local function ShowTradeSummary(player)
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
    print("|cFF33FF99Trade Summary with|r |cFFFFFF00" .. player .. "|r:")
    
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

-- Update the TRADE_SHOW event to handle water and food trades
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MyAddOn" then
            print("|cFF33FF99MyAddOn|r has been loaded successfully! Type |cFFFFFF00/myaddon|r or |cFFFFFF00/ma|r to toggle.")
        end
        return -- Always process ADDON_LOADED regardless of enabled state
    end
    
    -- Skip other event processing if addon is disabled
    if not addonEnabled and event ~= "ADDON_LOADED" then 
        return 
    end
    
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
                TradePortal.SetPlayerPortalPurchaseStatus(Utils.StripRealm(playerName), TradePortal.PURCHASE_STATUS.PENDING_TRADE)
                
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
        SetRaidTarget("player", 1)  -- 1 = Yellow Star
        
        -- Continue with your existing code
        TradeProximityMonitor.Start()

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
    
            -- If player is not buying a port
            if TradePortal.GetPlayerPortalPurchaseStatus(player) == nil then
                TradeFood.Fill()
            end
        end

    elseif event == "TRADE_REQUEST_CANCEL" or event == "TRADE_CLOSED" then
        TradeTimeoutMonitor.Stop()

    elseif event == "TRADE_ACCEPT_UPDATE" then
        local playerAccepted, targetAccepted = ...
        local player = UnitName("NPC")

        -- Check if player is not buying a port
        if TradePortal.GetPlayerPortalPurchaseStatus(player) == nil then
            C_Timer.NewTimer(1, function()
                AcceptTrade()
            end)
            return
        end
        
         -- For portal trades
        if targetAccepted == 1 and playerAccepted == 0 then
            -- The other player has accepted but we haven't yet
            -- Verify the money is correct before accepting
            if TradePortal.VerifyPortalPurchase(player) then
                AcceptTrade()
            end
        elseif playerAccepted == 1 and targetAccepted == 1 then            
            TradeTimeoutMonitor.Stop()

            TradePortal.SetPlayerPortalPurchaseStatus(Utils.StripRealm(player), TradePortal.PURCHASE_STATUS.PAID)
            
            -- Show trade summary
            ShowTradeSummary(player)
            
            -- Cast the portal spell
            local destination = Destinations.GetPlayerDestination(Utils.StripRealm(player))
            if destination then
                Spells.CastPortal(destination)
            else
                print("Error: No destination set for player " .. player)
            end
        end

    elseif event == "TRADE_MONEY_CHANGED" then
        local player = UnitName("NPC")

         -- Check if not buying a port
        if TradePortal.GetPlayerPortalPurchaseStatus(player) == nil then
            -- Set timeout of 2 seconds, then accept trade
            C_Timer.NewTimer(1, function()
                AcceptTrade()
            end)
            return
        end
    elseif event == "TRADE_CLOSED" then
        TradeTimeoutMonitor.Stop()
    end
end)
