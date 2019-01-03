--
-- Created by Ikamari, 16.12.2018 14:05
--

-- COS
local Window    = require "system.window"
-- OOS
local component = require "component"
local gpu       = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

POP_UP_COLORS = {
    defaultFrameColor      = 0x555547,
    defaultBackgroundColor = 0x282828,
    defaultForegroundColor = 0xa59c83,
    defaultWindowNameColor = 0xa59c83,

    warningFrameColor      = 0x555547,
    warningBackgroundColor = 0x282828,
    warningForegroundColor = 0xa59c83,
    warningWindowNameColor = 0xCDCD00,

    errorFrameColor        = 0x555547,
    errorBackgroundColor   = 0x282828,
    errorForegoundColor    = 0xa59c83,
    errorWindowNameColor   = 0xDC143C,
}

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
    properties.frameColor      = POP_UP_COLORS[properties.type .. "FrameColor"]      or properties.frameColor
    properties.backgroundColor = POP_UP_COLORS[properties.type .. "BackgroundColor"] or properties.backgroundColor
    properties.foregroundColor = POP_UP_COLORS[properties.type .. "ForegroundColor"] or properties.foregroundColor
    properties.windowNameColor = POP_UP_COLORS[properties.type .. "WindowNameColor"] or properties.windowNameColor
end

function PopUp:renderContent(hex)
    gpu.setForeground(hex and hex or self.foregroundColor)
    gpu.set(self.contentX, self.contentY, self.text)
end

return PopUp