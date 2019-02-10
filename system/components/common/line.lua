-- InfOS
local UIComponent   = require "system.components.component"
-- OpenOS
local component     = require "component"
local gpu           = component.gpu

---@class Line : UIComponent
local Line = UIComponent:inherit({
    doFrameRender      = false,
    doBackgroundRender = false,
    hasDefaultSize     = true,
    contentSideIndent  = 0
})

function Line:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.orientation = parameters.orientation
    if (properties.orientation == "horizontal") then
        if (not parameters.width) then
            error("Line component with \"horizontal\" orientation must receive \"width\" parameter")
        end
        properties.width  = parameters.width
        properties.height = 1
        properties.symbol = "─"
    elseif (properties.orientation == "vertical") then
        if (not parameters.height) then
            error("Line component with \"vertical\" orientation must receive \"height\" parameter")
        end
        properties.width  = 1
        properties.height = parameters.height
        properties.symbol = "│"
    else
        error("Line component must have \"horizontal\" or \"vertical\" orientation")
    end

    -- Call parent constructor
    UIComponent:constructor(properties, parameters)

    properties.color  = parameters.color  or properties.frameColor
    properties.symbol = parameters.symbol or properties.symbol
end

function Line:renderContent()
    gpu.setForeground(self.color)
    gpu.setBackground(self.parent.backgroundColor)

    gpu.fill(self.contentX, self.contentY, self.width, self.height, self.symbol)

    return true
end

return Line