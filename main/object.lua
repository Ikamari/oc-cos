-- Basic object
local Object = {}

function Object:new(properties, parameters, inheritance)
    properties = properties or {}
    parameters = parameters or {}

    -- Call constructor only when initializing object
    if self.constructor ~= nil and inheritance ~= true then
        self:constructor(_, parameters)
    end

    -- Initialization part
    setmetatable(properties, self)
    self.__index = self
    return properties
end

function Object:constructor(properties, parameters) end

function Object:inherit(properties)
    return self:new(_, _, true):new(properties, _, true)
end

return Object