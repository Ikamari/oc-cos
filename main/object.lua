-- Basic object
local Object = {}

function Object:new(properties, parameters, inheritance)
    properties = properties or {}
    parameters = parameters or {}

    -- Initialization part
    setmetatable(properties, self)
    self.__index = self

    -- Call constructor only when initializing object
    if self.constructor ~= nil and inheritance ~= true then
        self:constructor(properties, parameters)
    end

    return properties
end

function Object:constructor(properties, parameters) end

function Object:inherit(properties)
    return self:new(_, _, true):new(properties, _, true)
end

return Object