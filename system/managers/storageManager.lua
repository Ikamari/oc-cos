-- InfOS
local Object  = require "system.main.object"

---@class StorageManager
---You must initialize it before use
---@field public system OS
local StorageManager = Object:inherit({
    initialized = false
})

function StorageManager:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if type(parameters.rootPath) ~= "string" then
        error("Config manager must receive root path")
    end

    properties.storagePath = parameters.rootPath .. "storage/"
    properties.system      = parameters.system
    properties.initialized = true
end

function StorageManager:exists(fileName)
    return self.system.file:exists(self.storagePath .. fileName)
end

function StorageManager:create(fileName, data, serialize)
    return self.system.file:write(self.storagePath .. fileName, data, serialize)
end

function StorageManager:remove(fileName)
    self.system.file:remove(self.storagePath .. fileName)
    return true
end

function StorageManager:get(fileName, unserialize, valueName)
    -- Get current config values
    local fileData = self.system.file:read(self.storagePath .. fileName, unserialize)

    if unserialize ~= false and valueName then
        return fileData[valueName]
    end

    return fileData
end

function StorageManager:list(filter)
    return self.system.file:list(self.storagePath, filter, true)
end

return StorageManager