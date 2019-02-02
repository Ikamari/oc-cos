-- COS
local Window     = require "system.window"
local constants  = require "system.constants"
local Button     = require "system.components.common.Button"
local TextField  = require "system.components.common.textField"
-- OOS
local component = require "component"
local gpu       = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

local PopUp = Window:inherit({
    -- Properties
    windowX      = screenWidth  * 0.25,
    windowY      = screenHeight * 0.5 - 3,
    windowWidth  = screenWidth  * 0.5,
    windowHeight = 6,

    autoSize     = false
    --
})

function PopUp:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if (parameters.doCloseButtonRender ~= nil) then
        properties.doCloseButtonRender = parameters.doCloseButtonRender
    end

    -- Call parent constructor
    Window:constructor(properties)

    properties.windowName   = parameters.windowName or "Всплывающее окно"
    properties.text         = parameters.text or ""
    properties.centeredText = parameters.centeredText or false
    properties.type         = parameters.type or "default"

    properties.windowNameColor       = constants[properties.type .. "StringColor"] or properties.windowNameColor
    properties.doConfirmButtonRender = parameters.doConfirmButtonRender or false
    properties.doDenyButtonRender    = parameters.doDenyButtonRender    or false
    properties.confirmButtonText     = parameters.confirmButtonText     or "Да"
    properties.denyButtonText        = parameters.denyButtonText        or "Нет"

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
                properties:terminate(false)
            end
        })
        properties.components[#properties.components + 1] = denyButton
    end
end

return PopUp