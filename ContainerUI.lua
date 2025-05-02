------------------------------------------
-- Container UI Module
------------------------------------------
local MageService = MAGESERVICE
local Blacklist = MageService.Blacklist
local Settings = MageService.Settings

------------------------------------------
-- Create the ContainerUI module
------------------------------------------
local ContainerUI = {}

------------------------------------------
-- UI Elements
------------------------------------------

-- Create a movable container frame
ContainerUI.Frame = CreateFrame("Frame", "MageServiceContainer", UIParent)
ContainerUI.Frame:SetSize(170, 200) -- Increased height to accommodate buttons
-- Initial position will be set during initialization
ContainerUI.Frame:SetMovable(true)
ContainerUI.Frame:EnableMouse(true)
ContainerUI.Frame:SetClampedToScreen(true)
ContainerUI.Frame:RegisterForDrag("LeftButton")
ContainerUI.Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
ContainerUI.Frame:SetScript("OnDragStop", function(self) 
    self:StopMovingOrSizing()
    -- Save position for future sessions
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    Settings.SetContainerUIPosition({
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    })
end)

-- Add a background and border to make it visible when empty
ContainerUI.Frame.bg = ContainerUI.Frame:CreateTexture(nil, "BACKGROUND")
ContainerUI.Frame.bg:SetAllPoints()
ContainerUI.Frame.bg:SetColorTexture(0, 0, 0, 0.5)

-- Add a header/title for dragging
ContainerUI.Frame.header = ContainerUI.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ContainerUI.Frame.header:SetPoint("TOP", 0, -5)
ContainerUI.Frame.header:SetText("Mage Service")

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
        ContainerUI.Hide()
    else
        ContainerUI.Show()
    end
end

-- Function to show container
function ContainerUI.Show()
    ContainerUI.UpdateContainerSize()
    ContainerUI.Frame:Show()
    Settings.SetContainerUIVisible(true)
end

-- Function to hide container
function ContainerUI.Hide()
    ContainerUI.Frame:Hide()
    Settings.SetContainerUIVisible(false)
end

-- Function to initialize the container UI from saved settings
function ContainerUI.Initialize()
    -- Set the position from saved settings
    local position = Settings.GetContainerUIPosition()
    if position then
        ContainerUI.Frame:ClearAllPoints()
        ContainerUI.Frame:SetPoint(
            position.point, 
            UIParent, 
            position.relativePoint, 
            position.xOfs, 
            position.yOfs
        )
    end
    
    -- Set visibility from saved settings
    if Settings.IsContainerUIVisible() then
        ContainerUI.Show()
    else
        ContainerUI.Hide()
    end
end

------------------------------------------
-- Register the module in the addon namespace
------------------------------------------
MageService.ContainerUI = ContainerUI