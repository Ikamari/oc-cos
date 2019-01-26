--
-- Created by Ikamari, 04.01.2019 12:02
--

-- COS
local Object  = require "system.main.object"
-- OOS
local srl        = require "serialization"
local filesystem = require "filesystem"

local ConfigHelper = Object:inherit({
    initialized = false
})

function ConfigHelper:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if type(parameters.rootPath) ~= "string" then
        error("Config manager must receive root path")
    end

    properties.initialized = true
    properties.configsPath = parameters.rootPath .. "system/configs"
end

function ConfigHelper:getConfigFileValues(configFilePath)
    if not self.initialized then
        error("Config manager must be initialized")
    end
    
    -- Check whether specified config file exists
    if (not filesystem.exists(configFilePath)) then
        error("Config file \"" .. configFilePath .. "\" does not exist")
    end

    -- Unserialize content of config file
    local configFile = io.open(configFilePath, "r")
    local serializedConfigValues = configFile:read("*a")
    configFile:close()
    return srl.unserialize(serializedConfigValues)
end

-- Also can be used to create config file
function ConfigHelper:setConfigFileValues(configFilePath, serializedValues)
    if not self.initialized then
        error("Config manager must be initialized")
    end

    -- Create new config file with specified values
    local configFile = io.open(configFilePath, "w")
    configFile:write(serializedValues)
    configFile:close()
end

function ConfigHelper:exist(configName)
    if not self.initialized then
        error("Config manager must be initialized")
    end
    
    local configFilePath = self.configsPath .. "/" .. configName .. ".cfg"
    return filesystem.exists(configFilePath)
end

function ConfigHelper:create(configName, initialValues)
    if not self.initialized then
        error("Config manager must be initialized")
    end

    local configFilePath = self.configsPath .. "/" .. configName .. ".cfg"
    local serialized = srl.serialize(initialValues)

    self:setConfigFileValues(configFilePath, serialized)
end

function ConfigHelper:get(configName, valueName)
    if not self.initialized then
        error("Config manager must be initialized")
    end

    local configFilePath = self.configsPath .. "/" .. configName .. ".cfg"
    local configValues   = self:getConfigFileValues(configFilePath)

    -- Return specified/all config value(s)
    if type(valueName) == "string" then
        return configValues[valueName]
    else
        return configValues
    end
end

function ConfigHelper:setValue(configName, valueName, newValue)
    if not self.initialized then
        error("Config manager must be initialized")
    end

    local configFilePath = self.configsPath .. "/" .. configName .. ".cfg"
    local configValues   = self:getConfigFileValues(configFilePath)

    -- Update specified value in config
    configValues[valueName] = newValue
    local serialized = srl.serialize(configValues)

    self:setConfigFileValues(configFilePath, serialized)
end

function ConfigHelper:setValues(configName, values)
    if not self.initialized then
        error("Config manager must be initialized")
    end

    local configFilePath = self.configsPath .. "/" .. configName .. ".cfg"
    local configValues   = self:getConfigFileValues(configFilePath)

    -- Update specified value in config
    for key, value in pairs(values) do
        configValues[key] = value
    end
    local serialized = srl.serialize(configValues)

    self:setConfigFileValues(configFilePath, serialized)
end

return ConfigHelper