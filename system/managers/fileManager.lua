-- InfOS
local Object  = require "system.main.object"
-- OpenOS
local srl        = require "serialization"
local filesystem = require "filesystem"

---@class FileManager
---You must initialize it before use
---@field public system OS
local FileManager = Object:inherit({
    initialized = false
})

function FileManager:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.system      = parameters.system
    properties.initialized = true
end

function FileManager:read(filePath, unserialize)
    -- Define whether file content should be unserialized
    if unserialize == nil then
        unserialize = true
    end

    -- Check whether specified file exists
    if (not filesystem.exists(filePath)) then
        error("File \"" .. filePath .. "\" does not exist")
    end

    local file        = io.open(filePath, "r")
    local fileContent = file:read("*a")
    file:close()

    return unserialize and srl.unserialize(fileContent) or fileContent
end

function FileManager:write(filePath, data, serialize)
    data = data or ""
    -- Define whether data should be serialized
    if serialize == nil then
        serialize = true
    end

    -- Create new config file with specified values
    local file, fileError = io.open(filePath, "w")

    -- Check whether file was successfully opened for writing
    if not file then
        return false, fileError
    end

    local result, writeError = file:write(serialize and srl.serialize(data) or data)

    -- Check whether data was successfully written to file
    if not result then
        return false, writeError
    end

    file:close()
    return true
end

function FileManager:remove(filePath)
    -- Check whether specified file exists
    if (not filesystem.exists(filePath)) then
        error("File \"" .. filePath .. "\" does not exist")
    end

    filesystem.remove(filePath)
end

function FileManager:exists(filePath)
    return filesystem.exists(filePath)
end

function FileManager:list(directoryPath, filter, skipDirectories)
    local list = {}
    for file in filesystem.list(directoryPath) do
        if skipDirectories then
            if file:find("/$") then
                goto continue
            end
        end

        if filter then
            if not file:find(filter) then
                goto continue
            end
        end

        list[#list + 1] = file
        ::continue::
    end
    return list
end

return FileManager