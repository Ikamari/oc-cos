--
-- Created by Ikamari, 22.12.2018 22:04
--

-- COS
local UIComponent   = require "system.ui.uiComponent"
local StringHelper  = require "system.helpers.stringHelper"
-- OOS
local component     = require "component"
local gpu           = component.gpu

local TextField = UIComponent:inherit({})

function TextField:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    UIComponent:constructor(properties, parameters)

    properties.textBackgroundColor = parameters.textBackgroundColor or nil
    properties.textForegroundColor = parameters.textForegroundColor or nil

    properties.text = parameters.text or ""
    properties:updateText(properties.text, properties)
end

function TextField:updateText(text, properties)
    properties       = properties or self
    properties.text  = text
    properties.lines = StringHelper:splitToLines(properties.text, properties.width, properties.height)
    properties:render()
end

function TextField:renderText()
    gpu.setForeground(self.textForegroundColor or self.parent.foregroundColor)
    gpu.setBackground(self.textBackgroundColor or self.parent.backgroundColor)

    local lineNumber = 0
    for _, line in pairs(self.lines) do
        gpu.set(self.posX, self.posY + lineNumber, line)
        lineNumber = lineNumber + 1
    end

    return true
end

function TextField:render()
    self:renderText()
end

return TextField
