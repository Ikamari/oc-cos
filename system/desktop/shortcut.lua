--
-- Created by Ikamari, 02.01.2019 16:18
--

-- COS
local Component    = require "system.component"
local constants    = require "system.constants"
local StringHelper = require "system.helpers.stringHelper"
-- OOS
local component = require "component"
local gpu       = component.gpu

local Shortcut = Component:inherit({
    icon       = false,
    label      = "Shortcut",
    isSelected = false,

    selectedBackgoundColor  = 0x919191,
    backgroundColor         = 0x535353,
    selectedForegroundColor = 0x282828,
    foregroundColor         = 0xa59c83
})

function Shortcut:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.posX     = parameters.posX or 1
    properties.posY     = parameters.posY or 1
    properties.contentX = parameters.posX + 1
    properties.contentY = parameters.posY + 1

    properties.label     = parameters.label or properties.label
    properties.realLabel = parameters.label or properties.label

    local labelLenght = StringHelper:getLength(properties.label)
    if labelLenght + 2 < constants.shortcutWidth then
        properties.labelIndent = math.floor((constants.shortcutWidth - labelLenght) / 2)
    else
        properties.labelIndent = 1
        properties.label = StringHelper:trim(properties.label, constants.shortcutWidth - 2)
    end

    properties.icon        = parameters.icon  or properties.icon
end

function Shortcut:switchSelectedState()
    self.isSelected = not self.isSelected
end

function Shortcut:renderLabel()
    gpu.setForeground(self.isSelected and self.selectedForegroundColor or self.foregroundColor)
    gpu.set(self.posX + self.labelIndent, self.posY + constants.shortcutHeight - 2, self.label)

    return true
end

function Shortcut:renderIcon()
    if not self.icon then
        return false
    end

    return true
end

function Shortcut:renderBackground()
    gpu.setBackground(self.isSelected and self.selectedBackgoundColor or self.backgroundColor)
    gpu.fill(self.posX, self.posY, constants.shortcutWidth, constants.shortcutHeight, " ")
    return true
end

function Shortcut:renderContent()
    self:renderBackground()
    self:renderLabel()
    self:renderIcon()
end

return Shortcut
