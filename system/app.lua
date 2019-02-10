-- InfOS
local Object        = require "system.main.object"
local ClickableZone = require "system.components.clickableZone"
-- OpenOS
local event         = require "event"
local component     = require "component"
local gpu           = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

---@class BasicApp
---@field public system OS
---@field public child  BasicApp|nil
---@field public parent BasicApp|nil
local BasicApp = Object:inherit({
    -- Properties
    parent = nil,
    child  = nil,

    terminated            = false,
    doEventHandling       = true,
    doProcessInterruption = true,

    frameColor        = 0x555547,
    backgroundColor   = 0x282828,
    foregroundColor   = 0xa59c83,
    windowNameColor   = 0xa59c83,
    closeButtonColor  = 0x555547,

    windowName        = "Приложение",
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

function BasicApp:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if not parameters.system then
        error("App must receive reference to system core as parameter")
    end

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

---@param ChildApp   BasicApp
---@param parameters table
---@param properties BasicApp
function BasicApp:call(ChildApp, parameters, properties)
    properties = properties or self
    parameters["system"] = properties.system
    parameters["parent"] = properties
    properties.child = ChildApp:new(_, parameters)
    local status = properties.child:run()
    properties.child = nil
    properties:update("down")
    return status
end

---@param Component  UIComponent
---@param parameters table
---@param properties BasicApp
---@return UIComponent
function BasicApp:addComponent(Component, parameters, properties, name)
    properties = properties or self
    parameters = parameters or {}
    parameters["parent"] = properties

    local uiComponent    = Component:new(_, parameters)
    local uiComponentKey = name or (#properties.components + 1)
    if uiComponent.canHandleKeyboardEvents then
        properties.inputComponents[uiComponentKey] = uiComponent
    else
        properties.components[uiComponentKey] = uiComponent
    end
    return uiComponent, uiComponentKey
end

---@return UIComponent
function BasicApp:getComponent(componentKey)
    if self.inputComponents[componentKey] then
        return self.inputComponents[componentKey]
    elseif self.components[componentKey] then
        return self.components[componentKey]
    end
    error("Trying to get unknown component")
end

function BasicApp:terminate(status)
    if self.child then
        self.child:terminate(status)
    end
    self:cancelEvents()
    if status ~= nil then
        self.status = status
    end
    self.terminated = true
end

function BasicApp:update(side)
    if self.parent and (side == "down" or side == "both") then
        self.parent.update("down")
    end
    self:render()
    if self.child and (side == "up" or side == "both") then
        self.child:update("up")
    end
end

function BasicApp:addEvent(eventId, eventKey)
    eventKey = eventKey or eventId
    self.events[eventKey] = eventId
    return eventId
end

function BasicApp:cancelEvents()
    for key in pairs(self.events) do
        self:cancelEvent(key)
    end
end

function BasicApp:cancelEvent(eventKey)
    if self.events[eventKey] then
        event.cancel(self.events[eventKey])
        self.events[eventKey] = nil
        return true
    end
    return false
end

function BasicApp:switchEventHandling()
    self.doEventHandling = not self.doEventHandling
end

function BasicApp:renderCloseButton()
    if self.doCloseButtonRender == false then
        return false
    end

    gpu.setForeground(self.closeButtonColor)
    gpu.set(self.closeButtonX, self.windowY, " × ")

    return true
end

function BasicApp:renderWindowName()
    if not self.doWindowNameRender then
        return false
    end

    gpu.setForeground(self.windowNameColor)
    gpu.set(self.windowX + self.windowNameIndent, self.windowY, ' ' .. self.windowName .. ' ')

    return true
end

function BasicApp:renderFrame()
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

function BasicApp:renderBackground()
    if not self.doBackgroundRender then
        return false
    end

    gpu.setBackground(self.backgroundColor)
    gpu.fill(self.windowX, self.windowY, self.windowWidth, self.windowHeight, " ")

    return true
end

function BasicApp:renderComponents()
    for key, uiComponent in pairs(self.components) do
        uiComponent:render()
    end
    for key, uiComponent in pairs(self.inputComponents) do
        uiComponent:render()
    end
end

function BasicApp:renderContent() end

function BasicApp:processInterruptEvent()
    if self.doProcessInterruption then
        self:terminate()
    end
end

function BasicApp:processTouchEvent(address, posX, posY, button, playerName)
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

function BasicApp:processDragEvent() end

function BasicApp:processKeyDownEvent(address, char, code, playerName)
    for key, handler in pairs(self.keyDownHandlers) do
        handler(char, code)
    end
    for key, uiComponent in pairs(self.inputComponents) do
        uiComponent:onKeyDown(char, code)
    end
end

function BasicApp:processAddedFloppyEvent(address)
    if self.system.drive:check(address, true) then
        self.system.drive:run(self)
    end
end

function BasicApp:processRemovedFloppyEvent(address)
    self.system.drive:forget(address)
end

function BasicApp:render()
    self:renderBackground()
    self:renderFrame()
    self:renderWindowName()
    self:renderCloseButton()
    self:renderComponents()
    self:renderContent()
end

function BasicApp:run()
    self:render()

    -- Main loop
    while true do
        if self.doEventHandling then
            local id, a, b, c, d, e = event.pullMultiple("interrupted", "touch", "drag", "key_down", "component_added", "component_removed")
            if id == "interrupted" then
                self:processInterruptEvent()
            elseif id == "drag" then
                self:processDragEvent(a, b, c, d, e)
            elseif id == "touch" then
                self:processTouchEvent(a, b, c, d, e)
            elseif id == "key_down" then
                self:processKeyDownEvent(a, b, c, d, e)
            elseif id == "component_added" and b == "filesystem" then
                self:processAddedFloppyEvent(a)
            elseif id == "component_removed" and b == "filesystem" then
                self:processRemovedFloppyEvent(a)
            end
        end
        if self.terminated then
            break
        end
    end

    return self.status
end

return BasicApp