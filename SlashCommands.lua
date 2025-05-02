------------------------------------------
-- Slash Commands Module
------------------------------------------
local MageService = MAGESERVICE
local Settings = MageService.Settings

------------------------------------------
-- Create the SlashCommands module
------------------------------------------
local SlashCommands = {}

------------------------------------------
-- Command Handler
------------------------------------------
local function HandleCommand(msg)
    msg = string.lower(msg or "")
    
    if msg == "on" then
        Settings.SetAddonEnabled(true)
        print("|cFF33FF99MageService:|r |cFF00FF00Enabled|r")
    elseif msg == "off" then
        Settings.SetAddonEnabled(false)
        print("|cFF33FF99MageService:|r |cFFFF0000Disabled|r")
    elseif msg == "show" then
        if MageService.ContainerUI then
            MageService.ContainerUI.Show()
            print("|cFF33FF99MageService:|r UI shown")
        end
    elseif msg == "hide" then
        if MageService.ContainerUI then
            MageService.ContainerUI.Hide()
            print("|cFF33FF99MageService:|r UI hidden")
        end
    elseif msg == "help" then
        print("|cFF33FF99MageService Commands:|r")
        print("|cFFFFFFFF/mageservice|r or |cFFFFFFFF/ms|r - Toggle addon on/off")
        print("|cFFFFFFFF/mageservice on|r - Enable addon")
        print("|cFFFFFFFF/mageservice off|r - Disable addon")
        print("|cFFFFFFFF/mageservice show|r - Show UI container")
        print("|cFFFFFFFF/mageservice hide|r - Hide UI container")
        print("|cFFFFFFFF/mageservice help|r - Show this help message")
    else
        -- Toggle if no specific command
        local addonEnabled = not Settings.IsAddonEnabled()
        Settings.SetAddonEnabled(addonEnabled)
        if addonEnabled then
            print("|cFF33FF99MageService:|r |cFF00FF00Enabled|r")
        else
            print("|cFF33FF99MageService:|r |cFFFF0000Disabled|r")
        end
    end
end

------------------------------------------
-- Initialize Module
------------------------------------------
function SlashCommands.Initialize()
    -- Register slash commands
    SLASH_MAGESERVICE1 = "/mageservice"
    SLASH_MAGESERVICE2 = "/ms"
    SlashCmdList["MAGESERVICE"] = HandleCommand
    
    print("|cFF33FF99MageService:|r Type |cFFFFFFFF/mageservice help|r for available commands")
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageService.SlashCommands = SlashCommands