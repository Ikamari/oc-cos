--
-- Created by Ikamari, 19.01.2019 11:33
--

-- COS
local Object        = require "system.main.object"
local ClickableZone = require "system.components.clickableZone"

local UIComponent = Object:inherit({
    mustHaveParentReference = true,
    hasDefaultSize          = false
})

function UIComponent:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if (not parameters.parent and properties.mustHaveParentReference) then
        error("Component must receive reference to it's parent as parameter")
    end
    properties.parent = parameters.parent

    if (not properties.hasDefaultSize) then
        if type(parameters.width) ~= "number" or type(parameters.height) ~= "number" then
            error("Component must receive \"width\" and height\" number parameters")
        end

        properties.width  = parameters.width
        properties.height = parameters.height
    end

    if type(parameters.posX) ~= "number" or type(parameters.posY) ~= "number" then
        error("Component must receive \"posX\" and \"posY\" number parameters")
    end

    properties.posX = parameters.posX
    properties.posY = parameters.posY

    if parameters.onTouchCallback and type(parameters.onTouchCallback) ~= "function" then
        error("Component must receive \"onTouchCallback\" parameter of \"function\" type")
    end
    if parameters.onFailedTouchCallbac and type(parameters.onFailedTouchCallback) ~= "function" then
        error("Component must receive \"onFailedTouchCallback\" parameter of \"function\" type")
    end

    properties.onTouchCallback       = parameters.onTouchCallback or function() end
    properties.onFailedTouchCallback = parameters.onFailedTouchCallback or function() end

    local clickableZone = ClickableZone:new(_, {
        x      = properties.posX,
        y      = properties.posY,
        width  = properties.width,
        height = properties.height,
        type   = "zone",
        parent = properties,
        callback = function (properties, _, parameters)
            properties:onTouch(parameters)
        end,
        onFailCallback = function (properties, _, parameters)
            properties:onFailedTouch(parameters)
        end
    })
    properties.clickableZone = clickableZone
end

function UIComponent:onTouch()
    self.onTouchCallback()
end

function UIComponent:onFailedTouch()
    self.onFailedTouchCallback()
end

function UIComponent:render()
end

return UIComponent
