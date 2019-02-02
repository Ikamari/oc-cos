local Object = require "system.main.object"

---@class ClickableZone
local ClickableZone = Object:inherit({
    initialized = false,
    debug       = false
})

function ClickableZone:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if parameters.type ~= "zone" and parameters.type ~= "point" then
        error("Clickable zone must be \"zone\" or \"point\" type")
    end

    if type(parameters.x) ~= "number" or type(parameters.y) ~= "number" then
        error("Clickable zone must receive \"x\" and \"y\" number parameters")
    end

    if parameters.type == "zone" and (type(parameters.width) ~= "number" or type(parameters.height) ~= "number") then
        error("Clickable zone with type \"zone\" must receive \"width\" and \"height\" number parameters")
    end

    if type(parameters.parent) ~= "table" then
        error("Clickable zone must receive \"parent\" table parameter")
    end

    if type(parameters.callback) ~= "function" then
        error("Clickable zone must receive \"callback\" function parameter")
    end

    properties.initialized = true
    properties.debug = parameters.debug or properties.debug
    properties.type  = parameters.type
    properties.minX  = parameters.x
    properties.minY  = parameters.y
    if parameters.type == "zone" then
        properties.maxX = parameters.width  + parameters.x - 1
        properties.maxY = parameters.height + parameters.y - 1
    end

    properties.parent             = parameters.parent
    properties.callback           = parameters.callback
    properties.onFailCallback     = parameters.onFailCallback or false
    properties.callbackParameters = parameters.callbackParameters or {}
end

-- Check whether user have clicked the clickable zone/point
function ClickableZone:check(x, y, parameters)
    if not self.initialized then
        error("Clickable zone must be initialized")
    end

    parameters = parameters or {}
    parameters["x"] = x
    parameters["y"] = y

    if self.debug then
        print("x:", x, "y:", y)
        print("minX:", self.minX, "maxX:", self.maxX, "minY:", self.minY, "maxY:", self.maxY)
    end

    if self.type == "zone" then
        if (self.minX <= x and x <= self.maxX) and (self.minY <= y and y <= self.maxY) then
            self.callback(self.parent, self.callbackParameters, parameters)
        else
            if self.onFailCallback ~= false then
                self.onFailCallback(self.parent, self.callbackParameters, parameters)
            end
        end
    else
        if self.minX == x and self.minY == y then
            self.callback(self.parent, self.callbackParameters, parameters)
        else
            if self.onFailCallback ~= false then
                self.onFailCallback(self.parent, self.callbackParameters, parameters)
            end
        end
    end
end

return ClickableZone