-- COS
local Object  = require "system.main.object"

---@class ConfigManager
---You must initialize it before use
---@field public system OS
local ConfigManager = Object:inherit({
    initialized = false
})

function ConfigManager:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if type(parameters.rootPath) ~= "string" then
        error("Config manager must receive root path")
    end

    properties.configsPath = parameters.rootPath .. "system/configs/"
    properties.system = parameters.system
    properties.initialized = true
end

function ConfigManager:exists(configName)
    return self.system.file:exists(self.configsPath .. configName .. ".cfg")
end

function ConfigManager:create(configName, initialValues)
    self.system.file:write(self.configsPath .. configName .. ".cfg", initialValues)
end

function ConfigManager:get(configName, valueName)
    -- Get current config values
    local configValues = self.system.file:read(self.configsPath .. configName .. ".cfg")

    -- Return specified/all config value(s)
    if type(valueName) == "string" then
        return configValues[valueName]
    else
        return configValues
    end
end

function ConfigManager:setValue(configName, valueName, newValue)
    -- Get current config values
    local configValues = self.system.file:read(self.configsPath .. configName .. ".cfg")

    -- Update specified value in config
    configValues[valueName] = newValue
    self.system.file:write(self.configsPath .. configName .. ".cfg", configValues)
end

function ConfigManager:setValues(configName, values)
    -- Get current config values
    local configValues = self.system.file:read(self.configsPath .. configName .. ".cfg")

    -- Update specified value in config
    for key, value in pairs(values) do
        configValues[key] = value
    end

    self.system.file:write(self.configsPath .. configName .. ".cfg", configValues)
end

return ConfigManager