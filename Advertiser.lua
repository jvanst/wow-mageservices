------------------------------------------
-- Advertiser Module
------------------------------------------
local MageService = MAGESERVICE
local ContainerUI = MageService.ContainerUI

------------------------------------------
-- Create the Advertiser module
------------------------------------------
local Advertiser = {}

------------------------------------------
-- Configuration
------------------------------------------
-- Advertisement messages
Advertiser.Messages = {
    general = "Mage 55 Water & Food at SW Fountain • Open Trade • Tips appreciated • Whisper 'inv' to buy port for 1g",
}

-- Cooldowns
Advertiser.lastMessageTime = 0
Advertiser.COOLDOWN_SECONDS = 60 -- 1 minute cooldown

------------------------------------------
-- Advertising Functions
------------------------------------------

-- Function to send advertisements
function Advertiser.SendMessage(messageType)
    -- Check cooldown
    local currentTime = GetTime()
    if currentTime - Advertiser.lastMessageTime < Advertiser.COOLDOWN_SECONDS then
        local remainingCooldown = math.ceil(Advertiser.COOLDOWN_SECONDS - (currentTime - Advertiser.lastMessageTime))
        print("|cFFFF0000Advertise on cooldown:|r " .. remainingCooldown .. " seconds remaining")
        return
    end
    
    -- Get the message to send
    local message = Advertiser.Messages[messageType or "general"]
    
    -- Send to yell and channel 1
    SendChatMessage(message, "YELL")
    SendChatMessage(message, "CHANNEL", nil, 1) -- 1 is the index for the General channel
    
    -- Update cooldown
    Advertiser.lastMessageTime = currentTime
    print("|cFF00FF00Advertisement sent!|r Button will be available in " .. Advertiser.COOLDOWN_SECONDS .. " seconds")
    
    -- Disable button during cooldown instead of hiding
    if Advertiser.Button then
        Advertiser.Button:Disable()
        Advertiser.Button:SetAlpha(0.5)
        
        -- Create a timer to enable the button after cooldown
        C_Timer.After(Advertiser.COOLDOWN_SECONDS, function()
            if Advertiser.Button then
                Advertiser.Button:Enable()
                Advertiser.Button:SetAlpha(1.0)
                print("|cFF00FF00Advertise button is now available!|r")
            end
        end)
    end
end

------------------------------------------
-- UI Elements
------------------------------------------

Advertiser.Container = ContainerUI.Frame
    
Advertiser.Button = CreateFrame("Button", "MageServiceAdvertiseButton", Advertiser.Container, "UIPanelButtonTemplate")

Advertiser.Button:SetSize(150, 30)
Advertiser.Button:SetText("Advertise")

-- Register with ContainerUI layout system (priority 50 - lowest position)
ContainerUI.RegisterButton(Advertiser.Button, 50)

-- Function to handle the Advertise button click
Advertiser.Button:SetScript("OnClick", function()
    Advertiser.SendMessage("general")
end)

-- Add tooltip
Advertiser.Button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Advertise your portal services")
    GameTooltip:AddLine("Sends a message to yell and general chat", 1, 1, 1)
    GameTooltip:AddLine("Cooldown: " .. Advertiser.COOLDOWN_SECONDS .. " seconds", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end)

Advertiser.Button:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageService.Advertiser = Advertiser