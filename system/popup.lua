-- InfOS
local BasicApp      = require "system.app"
local constants     = require "system.constants"
local ClickableZone = require "system.components.clickableZone"
-- Components
local Button     = require "system.components.common.Button"
local TextField  = require "system.components.common.textField"
-- OpenOS
local component = require "component"
local gpu       = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

---@class PopUp : BasicApp
local PopUp = BasicApp:inherit({
    windowName   = "Всплывающее окно",
    windowX      = screenWidth  * 0.25,
    windowY      = screenHeight * 0.5 - 3,
    windowWidth  = screenWidth  * 0.5,
    windowHeight = 6,

    blinkOnMiss  = true,

    autoSize     = false
})

---@param properties PopUp
function PopUp:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if (parameters.doCloseButtonRender ~= nil) then
        properties.doCloseButtonRender = parameters.doCloseButtonRender
    end

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)

    properties.windowName   = parameters.windowName or properties.windowName
    properties.text         = parameters.text or ""
    properties.centeredText = parameters.centeredText or false
    properties.type         = parameters.type or "default"

    properties.windowNameColor       = constants[properties.type .. "TextColor"] or properties.windowNameColor
    properties.doConfirmButtonRender = parameters.doConfirmButtonRender or false
    properties.doDenyButtonRender    = parameters.doDenyButtonRender    or false
    properties.confirmButtonText     = parameters.confirmButtonText     or "Да"
    properties.denyButtonText        = parameters.denyButtonText        or "Нет"

    if (parameters.doProcessInterruption ~= nil) then
        properties.doProcessInterruption = parameters.doProcessInterruption
    end

    local hasButtons = properties.doConfirmButtonRender or properties.doDenyButtonRender or false
    if (hasButtons) then
        properties.windowHeight  = properties.windowHeight + 2
        properties.contentHeight = properties.contentHeight + 2
    end

    local textField = TextField:new(_, {
        parent = properties,
        posX   = properties.contentX,
        posY   = properties.contentY,
        width  = properties.contentWidth,
        height = properties.contentHeight - (hasButtons and 2 or 0),
        text   = properties.text,
        centeredText = properties.centeredText
    })
    properties.components[#properties.components + 1] = textField

    properties.onConfirmCallback = parameters.onConfirmCallback or function() end
    properties.onDenyCallback    = parameters.onDenyCallback    or function() end

    local buttonWidth = properties.contentWidth * 0.45
    if (properties.doConfirmButtonRender) then
        local confirmButton = Button:new(_, {
            parent = properties,
            text   = properties.confirmButtonText,
            posX   = properties.doDenyButtonRender and properties.contentX + 2 or 0,
            posY   = properties.contentY + properties.contentHeight - 1,
            width  = buttonWidth,
            height = 1,
            horizontallyCentered = properties.doDenyButtonRender ~= true,
            onTouchCallback = function()
                properties.onConfirmCallback()
                properties:terminate(true)
            end
        })
        properties.components[#properties.components + 1] = confirmButton
    end

    if (properties.doDenyButtonRender) then
        local denyButton = Button:new(_, {
            parent = properties,
            text   = properties.denyButtonText,
            posX   = properties.doConfirmButtonRender and (properties.contentX + properties.contentWidth) - (buttonWidth + 1) or 0,
            posY   = properties.contentY + properties.contentHeight - 1,
            width  = buttonWidth,
            height = 1,
            horizontallyCentered = properties.doConfirmButtonRender ~= true,
            onTouchCallback = function()
                properties.onDenyCallback()
                properties:terminate(false)
            end
        })
        properties.components[#properties.components + 1] = denyButton
    end
end

return PopUp