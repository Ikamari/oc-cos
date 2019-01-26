--
-- Created by Ikamari, 16.12.2018 14:05
--

-- COS
local Window    = require "system.window"
local constants = require "system.constants"
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

    -- Call parent constructor
    Window:constructor(properties)

    properties.windowName = parameters.windowName or "Всплывающее окно"
    properties.text       = parameters.text or ""
    properties.type       = parameters.type or "default"

    -- Define which colors must be used in pop-up
    properties.frameColor      = properties.frameColor
    properties.backgroundColor = properties.backgroundColor
    properties.foregroundColor = properties.foregroundColor
    properties.windowNameColor = constants[properties.type .. "StringColor"] or properties.windowNameColor

    local textField = TextField:new(_, {
        parent = properties,
        posX   = properties.contentX,
        posY   = properties.contentY,
        width  = properties.contentWidth,
        height = properties.contentHeight,
        text   = properties.text
    })
    properties.components[#properties.components + 1] = textField
end

return PopUp