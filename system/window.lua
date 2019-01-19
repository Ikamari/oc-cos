--
-- Created by Ikamari, 14.12.2018 22:02
--

-- COS
local Object        = require "system.main.object"
local ClickableZone = require "system.ui.clickableZone"
-- OOS
local event         = require "event"
local component     = require "component"
local gpu           = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

local Window = Object:inherit({
    -- Properties
    terminated            = false,
    doEventHandling       = true,
    doProcessInterruption = true,

    frameColor        = 0x555547,
    backgroundColor   = 0x282828,
    foregroundColor   = 0xa59c83,
    windowNameColor   = 0xa59c83,
    closeButtonColor  = 0x555547,

    windowName        = "Window",
    windowNameIndent  = 1,    -- "left margin" in columns
    autoSize          = true, -- if true, then windowWidth = screenWidth - widnowX * 2 (same with height)

    doWindowFrameRender = true,
    doBackgroundRender  = true,
    doWindowNameRender  = true,
    doCloseButtonRender = true,

    closeButtonIndent = 3,    -- "right margin" in columns

    windowX         = 1,
    windowY         = 1,
    windowWidth     = screenWidth,
    windowHeight    = screenHeight,
    --
})

function Window:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.system = parameters.system

    properties.windowX = parameters.windowX or properties.windowX
    properties.windowY = parameters.windowY or properties.windowY

    properties.inheritBackgroundColor = gpu.getBackground()
    properties.inheritForegroundColor = gpu.getForeground()

    if properties.autoSize then
        properties.windowWidth  = screenWidth  - (properties.windowX * 2 - 1)
        properties.windowHeight = screenHeight - (properties.windowY * 2 - 1)
    else
        properties.windowWidth  = parameters.windowWidth  or properties.windowWidth
        properties.windowHeight = parameters.windowHeight or properties.windowHeight
    end

    properties.contentX      = properties.windowX + (properties.renderSideBorders and 4 or 2)
    properties.contentY      = properties.windowY + 2
    properties.contentWidth  = properties.windowWidth  - (properties.renderSideBorders and 8 or 4)
    properties.contentHeight = properties.windowHeight - 4

    properties.clickableZones     = {}
    properties.components         = {}
    properties.editableComponents = {}
end

function Window:switchEventHandling()
    self.doEventHandling = not self.doEventHandling
end

function Window:renderWindow()
    self:renderWindowBackground()
    self:renderWindowFrame()
    self:renderWindowName()
    self:renderCloseButton()
    self:renderContent()
end

function Window:renderCloseButton()
    if not self.doCloseButtonRender then
        return false
    end

    gpu.setForeground(self.closeButtonColor)

    local closeButtonX = self.windowX + self.windowWidth - self.closeButtonIndent - 1
    gpu.set(closeButtonX, self.windowY, " × ")
    local buttonPoint = ClickableZone:new(_, {
        x      = closeButtonX + 1,
        y      = self.windowY,
        type   = "point",
        parent = self,
        callback = function (properties)
            properties.terminated = true
        end
    })
    self.clickableZones[#self.clickableZones + 1] = buttonPoint

    return true
end

function Window:renderWindowName()
    if not self.doWindowNameRender then
        return false
    end

    gpu.setForeground(self.windowNameColor)
    gpu.set(self.windowX + self.windowNameIndent, self.windowY, ' ' .. self.windowName .. ' ')

    return true
end

function Window:renderWindowFrame()
    if not self.doWindowFrameRender then
        return false
    end

    gpu.setForeground(self.frameColor)
    -- top
    gpu.fill(self.windowX, self.windowY, self.windowWidth, 1, "━")
    -- bottom
    gpu.fill(self.windowX, self.windowY + self.windowHeight - 1, self.windowWidth, 1, "━")
    -- right
    gpu.fill(self.windowX + self.windowWidth - 1, self.windowY, 1, self.windowHeight, "┃")
    -- left
    gpu.fill(self.windowX, self.windowY, 1, self.windowHeight, "┃")
    -- top left corner
    gpu.set(self.windowX, self.windowY, "┏")
    -- top right corner
    gpu.set(self.windowX + self.windowWidth - 1, self.windowY, "┓")
    -- bottom left corner
    gpu.set(self.windowX, self.windowY + self.windowHeight - 1, "┗")
    -- bottom right corner
    gpu.set(self.windowX + self.windowWidth - 1, self.windowY + self.windowHeight - 1, "┛")

    return true
end

function Window:renderWindowBackground()
    if not self.doBackgroundRender then
        return false
    end

    gpu.setBackground(self.backgroundColor)
    gpu.fill(self.windowX, self.windowY, self.windowWidth, self.windowHeight, " ")

    return true
end

function Window:renderComponents()
    for key, uiComponent in pairs(self.components) do
        uiComponent:render()
    end
    for key, uiComponent in pairs(self.editableComponents) do
        uiComponent:render()
    end
end

function Window:renderContent()
    self:renderComponents()
end

function Window:processInterruptEvent()
    if self.doProcessInterruption then
--        gpu.setBackground(self.inheritBackroundColor)
--        gpu.setForeground(self.inheritForegroundColor)
--        gpu.fill(self.windowX, self.windowY, self.windowWidth, self.windowHeight, " ")
        self.terminated = true
    end
end

function Window:processTouchEvent(a, b, c, d)
    for key, zone in pairs(self.clickableZones) do
        zone:check(b, c)
    end
    for key, uiComponent in pairs(self.components) do
        uiComponent.clickableZone:check(b, c)
    end
    for key, uiComponent in pairs(self.editableComponents) do
        uiComponent.clickableZone:check(b, c)
    end
end

function Window:processDragEvent() end

function Window:processKeyDownEvent() end

function Window:init()
    self:renderWindow()

    -- Main loop
    while true do
        if self.doEventHandling then
            local id, a, b, c, d = event.pullMultiple("interrupted", "touch", "drag", "key_down")
            if id == "interrupted" then
                self:processInterruptEvent()
            elseif id == "drag" then
                self:processDragEvent(a, b, c, d)
            elseif id == "touch" then
                self:processTouchEvent(a, b, c, d)
            elseif id == "key_down" then
                self:processKeyDownEvent(a, b, c, d)
            end
        end
        if self.terminated then
            break
        end
    end
end

return Window