-- InfOS
local UIComponent   = require "system.components.component"
-- Helpers
local StringHelper  = require "system.helpers.stringHelper"
-- OpenOS
local component     = require "component"
local gpu           = component.gpu

---@class Button : UIComponent
local Button = UIComponent:inherit({})

function Button:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    UIComponent:constructor(properties, parameters)
    
    properties.text = parameters.text or ""
    local labelLength = StringHelper:getLength(properties.text)
    if labelLength + 2 < properties.contentWidth then
        properties.textIndent = math.floor((properties.contentWidth - labelLength) / 2)
    else
        properties.textIndent = 0
        properties.text = StringHelper:trim(properties.text, properties.contentWidth - 2)
    end
end

function Button:renderContent()
    gpu.setForeground(self.textForegroundColor)
    gpu.setBackground(self.textBackgroundColor)
    gpu.set(self.contentX + self.textIndent, self.contentY, self.text)

    return true
end

return Button

