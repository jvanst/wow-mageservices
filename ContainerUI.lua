------------------------------------------
-- Container UI Module
------------------------------------------
local MageServices = MAGESERVICES
local Blacklist = MageServices.Blacklist

------------------------------------------
-- Create the ContainerUI module
------------------------------------------
local ContainerUI = {}

------------------------------------------
-- UI Elements
------------------------------------------

-- Create a movable container frame
ContainerUI.Frame = CreateFrame("Frame", "MageServicesContainer", UIParent)
ContainerUI.Frame:SetSize(170, 200) -- Increased height to accommodate buttons
ContainerUI.Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
ContainerUI.Frame:SetMovable(true)
ContainerUI.Frame:EnableMouse(true)
ContainerUI.Frame:SetClampedToScreen(true)
ContainerUI.Frame:RegisterForDrag("LeftButton")
ContainerUI.Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
ContainerUI.Frame:SetScript("OnDragStop", function(self) 
    self:StopMovingOrSizing()
    -- Save position for future sessions (optional)
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    -- You could save these values to a saved variable table here
end)

-- Add a background and border to make it visible when empty
ContainerUI.Frame.bg = ContainerUI.Frame:CreateTexture(nil, "BACKGROUND")
ContainerUI.Frame.bg:SetAllPoints()
ContainerUI.Frame.bg:SetColorTexture(0, 0, 0, 0.5)

-- Add a header/title for dragging
ContainerUI.Frame.header = ContainerUI.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ContainerUI.Frame.header:SetPoint("TOP", 0, -5)
ContainerUI.Frame.header:SetText("MageServices")

------------------------------------------
-- Button Layout Management
------------------------------------------

-- Table to track all buttons in the container
ContainerUI.Buttons = {}

-- Function to register a button with the container
function ContainerUI.RegisterButton(button, priority)
    table.insert(ContainerUI.Buttons, {
        button = button,
        priority = priority or 100 -- Default priority (lower values = higher in the container)
    })
    
    -- Sort buttons by priority
    ContainerUI.LayoutButtons()
    
    return button
end

-- Function to layout all buttons in the container
function ContainerUI.LayoutButtons()
    -- Sort buttons by priority (lower values first)
    table.sort(ContainerUI.Buttons, function(a, b) 
        return a.priority < b.priority 
    end)
    
    local yOffset = -25 -- Start below the header
    local spacing = 5 -- Space between buttons
    
    -- Position each button
    for _, buttonInfo in ipairs(ContainerUI.Buttons) do
        local button = buttonInfo.button
        if button then
            button:ClearAllPoints()
            button:SetPoint("TOP", ContainerUI.Frame, "TOP", 0, yOffset)
            local _, height = button:GetSize()
            yOffset = yOffset - (height + spacing)
        end
    end
end

-- Function to update the container size based on visible buttons
function ContainerUI.UpdateContainerSize()
    local visibleButtons = 0
    local totalHeight = 30 -- Header space
    local buttonSpacing = 5
    
    for _, buttonInfo in ipairs(ContainerUI.Buttons) do
        if buttonInfo.button:IsShown() and buttonInfo.button:GetAlpha() > 0.1 then
            visibleButtons = visibleButtons + 1
            local _, height = buttonInfo.button:GetSize()
            totalHeight = totalHeight + height + buttonSpacing
        end
    end
    
    -- Minimum height to avoid empty container looking odd
    totalHeight = math.max(totalHeight, 50)
    
    -- Set the container height (keep width the same)
    local width = ContainerUI.Frame:GetWidth()
    ContainerUI.Frame:SetSize(width, totalHeight)
end

------------------------------------------
-- UI Functions
------------------------------------------

-- Function to toggle container visibility
function ContainerUI.ToggleVisibility()
    if ContainerUI.Frame:IsShown() then
        ContainerUI.Frame:Hide()
    else
        ContainerUI.UpdateContainerSize()
        ContainerUI.Frame:Show()
    end
end

------------------------------------------
-- Slash Commands
------------------------------------------

-- Create a slash command to toggle the frame
SLASH_PORTALFRAME1 = "/portalframe"
SlashCmdList["PORTALFRAME"] = function()
    ContainerUI.ToggleVisibility()
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageServices.ContainerUI = ContainerUI