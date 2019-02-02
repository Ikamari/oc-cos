-- COS
local Object        = require "system.main.object"
local ClickableZone = require "system.components.clickableZone"
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

    windowName        = "Окно",
    windowNameIndent  = 1,    -- "left margin" in columns
    autoSize          = true, -- if true, then windowWidth = screenWidth - widnowX * 2 (same with height)

    doFrameRender       = true,
    doBackgroundRender  = true,
    doWindowNameRender  = true,
    doCloseButtonRender = true,

    closeButtonIndent = 3,    -- "right margin" in columns

    windowX         = 1,
    windowY         = 1,
    windowWidth     = screenWidth,
    windowHeight    = screenHeight,
    contentIndent   = 2,

    status = 0 -- data that will be returned after successful termination of window
    --
})

function Window:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.system  = parameters.system

    properties.windowX = parameters.windowX or properties.windowX
    properties.windowY = parameters.windowY or properties.windowY

    if properties.autoSize then
        properties.windowWidth  = screenWidth  - (properties.windowX * 2 - 1)
        properties.windowHeight = screenHeight - (properties.windowY * 2 - 1)
    else
        properties.windowWidth  = parameters.windowWidth  or properties.windowWidth
        properties.windowHeight = parameters.windowHeight or properties.windowHeight
    end

    properties.contentX      = properties.windowX + properties.contentIndent
    properties.contentY      = properties.windowY + properties.contentIndent
    properties.contentWidth  = properties.windowWidth  - properties.contentIndent * 2
    properties.contentHeight = properties.windowHeight - properties.contentIndent * 2

    properties.keyDownHandlers = {}
    properties.clickableZones  = {}
    properties.components      = {}
    properties.inputComponents = {}
    properties.events          = {}

    if properties.doCloseButtonRender then
        properties.closeButtonX = properties.windowX + properties.windowWidth - properties.closeButtonIndent - 1
        local buttonPoint = ClickableZone:new(_, {
            x      = properties.closeButtonX + 1,
            y      = properties.windowY,
            type   = "point",
            parent = properties,
            callback = function (properties)
                properties:terminate()
            end
        })
        properties.clickableZones[#properties.clickableZones + 1] = buttonPoint
    end
end

function Window:terminate(status)
    self:cancelEvents()
    if status ~= nil then
        self.status = status
    end
    self.terminated = true
end

function Window:addEvent(eventId, eventKey)
    eventKey = eventKey or eventId
    self.events[eventKey] = eventId
    return eventId
end

function Window:cancelEvents()
    for key in pairs(self.events) do
        self:cancelEvent(key)
    end
end

function Window:cancelEvent(eventKey)
    if self.events[eventKey] then
        event.cancel(self.events[eventKey])
        self.events[eventKey] = nil
        return true
    end
    return false
end

function Window:switchEventHandling()
    self.doEventHandling = not self.doEventHandling
end

function Window:renderCloseButton()
    if self.doCloseButtonRender == false then
        return false
    end

    gpu.setForeground(self.closeButtonColor)
    gpu.set(self.closeButtonX, self.windowY, " × ")

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

function Window:renderFrame()
    if not self.doFrameRender then
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

function Window:renderBackground()
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
    for key, uiComponent in pairs(self.inputComponents) do
        uiComponent:render()
    end
end

function Window:renderContent() end

function Window:processInterruptEvent()
    if self.doProcessInterruption then
        self:terminate()
    end
end

function Window:processTouchEvent(address, posX, posY, button, playerName)
    for key, uiComponent in pairs(self.inputComponents) do
        uiComponent.clickableZone:check(posX, posY)
    end
    for key, zone in pairs(self.clickableZones) do
        zone:check(posX, posY)
    end
    for key, uiComponent in pairs(self.components) do
        uiComponent.clickableZone:check(posX, posY)
    end
end

function Window:processDragEvent() end

function Window:processKeyDownEvent(address, char, code, playerName)
    for key, handler in pairs(self.keyDownHandlers) do
        handler(char, code)
    end
    for key, uiComponent in pairs(self.inputComponents) do
        uiComponent:onKeyDown(char, code)
    end
end

function Window:render()
    self:renderBackground()
    self:renderFrame()
    self:renderWindowName()
    self:renderCloseButton()
    self:renderComponents()
    self:renderContent()
end

function Window:init()
    self:render()

    -- Main loop
    while true do
        if self.doEventHandling then
            local id, a, b, c, d, e = event.pullMultiple("interrupted", "touch", "drag", "key_down")
            if id == "interrupted" then
                self:processInterruptEvent()
            elseif id == "drag" then
                self:processDragEvent(a, b, c, d, e)
            elseif id == "touch" then
                self:processTouchEvent(a, b, c, d, e)
            elseif id == "key_down" then
                self:processKeyDownEvent(a, b, c, d, e)
            end
        end
        if self.terminated then
            break
        end
    end

    return self.status
end

return Window