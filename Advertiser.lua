local MyAddOn = MYADDON
local ContainerUI = MyAddOn.ContainerUI

-- Create the Advertiser module
local Advertiser = {}

-- Advertisement messages
Advertiser.Messages = {
    general = "Mage 55 Water & Food at SW Fountain • Open Trade • Tips appreciated • Whisper 'inv' to buy port for 1g",
}

-- Cooldowns
Advertiser.lastMessageTime = 0
Advertiser.COOLDOWN_SECONDS = 60 -- 1 minute cooldown

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
    
    -- Hide the button during cooldown
    if Advertiser.Button then
        Advertiser.Button:Hide()
        
        -- Create a timer to show the button after cooldown
        C_Timer.After(Advertiser.COOLDOWN_SECONDS, function()
            if Advertiser.Button then
                Advertiser.Button:Show()
                print("|cFF00FF00Advertise button is now available!|r")
            end
        end)
    end
end

-- Create the advertise button
function Advertiser.CreateButton()
    -- Create the Advertise button within the Portal Caster container
    -- Assuming ContainerUI.PortalCasterFrame exists as the portal caster container
    local parentFrame = ContainerUI.PortalCasterFrame or ContainerUI.Frame
    
    local AdvertiseButton = CreateFrame("Button", "MyAddOnAdvertiseButton", parentFrame, "UIPanelButtonTemplate")
    AdvertiseButton:SetSize(150, 30)
    
    -- Position at the bottom of the portal caster container
    AdvertiseButton:SetPoint("BOTTOM", parentFrame, "BOTTOM", 0, 10)
    AdvertiseButton:SetText("Advertise Portals")
    
    -- Function to handle the Advertise button click
    AdvertiseButton:SetScript("OnClick", function()
        Advertiser.SendMessage("general")
    end)
    
    -- Add tooltip
    AdvertiseButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Advertise your portal services")
        GameTooltip:AddLine("Sends a message to yell and general chat", 1, 1, 1)
        GameTooltip:AddLine("Cooldown: " .. Advertiser.COOLDOWN_SECONDS .. " seconds", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    
    AdvertiseButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Store the button reference
    Advertiser.Button = AdvertiseButton
end

-- Initialize the Advertiser
function Advertiser.Init()
    Advertiser.CreateButton()
    print("Advertiser module initialized")
end

-- Call initialization
Advertiser.Init()

-- Register the module in the addon namespace
MyAddOn.Advertiser = Advertiser