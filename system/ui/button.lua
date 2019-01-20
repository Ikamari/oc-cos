--
-- Created by Ikamari, 19.01.2019 0:43
--

-- COS
local UIComponent   = require "system.ui.uiComponent"
local StringHelper  = require "system.helpers.stringHelper"
-- OOS
local component     = require "component"
local gpu           = component.gpu

local Button = UIComponent:inherit({})

function Button:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    UIComponent:constructor(properties, parameters)

    properties.frameColor           = parameters.frameColor or 0x555547
    properties.backgroundColor      = parameters.backgroundColor or 0x282828
    properties.labelBackgroundColor = parameters.backgroundColor or 0x7e7e7e
    properties.labelForegroundColor = parameters.foregroundColor or 0x282828

    properties.label = parameters.label or ""
    local labelLength = StringHelper:getLength(properties.label)
    if labelLength + 2 < properties.width then
        properties.labelIndent = math.floor((properties.width - labelLength) / 2)
    else
        properties.labelIndent = 1
        properties.label = StringHelper:trim(properties.label, properties.width - 2)
    end
end

function Button:renderLabel()
    gpu.setForeground(self.labelForegroundColor)
    gpu.setBackground(self.labelBackgroundColor)
    gpu.set(self.posX + self.labelIndent, self.posY, self.label)

    return true
end

function Button:renderFrame()
    gpu.setForeground(self.parent.backgroundColor)
    gpu.setBackground(self.frameColor)

    -- bottom
    gpu.fill(self.posX, self.posY + self.height, self.width, 1, "▆")

    gpu.setForeground(self.frameColor)
    gpu.setBackground(self.parent.backgroundColor)

    return true
end

function Button:renderBackground()
    gpu.setBackground(self.labelBackgroundColor)
    gpu.fill(self.posX, self.posY, self.width, 1, " ")

    return true
end

function Button:render()
    self:renderBackground()
    self:renderFrame()
    self:renderLabel()
end

return Button

