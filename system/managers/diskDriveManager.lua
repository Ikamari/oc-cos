-- COS
local Object  = require "system.main.object"
-- OOS
local computer   = require "computer"
local component  = require "component"

---@class DiskDriveManager
---You must initialize it before use
---@field public system OS
local DiskDriveManager = Object:inherit({
    initialized = false
})

function DiskDriveManager:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.system = parameters.system
    properties.initialized = true
end

--[[
    instruction.lua structure:
    {
        type    - type of "data" inserted floppy "has" (hack tool, software installer, etc)
        subtype - example: "reusable" or "disposable" hack tool
    }
]]--

function DiskDriveManager:check(address, doBeep)
    if type(address) ~= "string" then
        error("Address must be specified")
    end

    local shortAddress    = address:sub(0, 3)
    local instructionPath = "/mnt/" .. shortAddress .. "/instruction.dat"

    -- Check whether specified config file exists
    if self.system.file:exists(instructionPath) then
        local diskData = self.system.file:read(instructionPath)

        self.system.diskInserted = true
        self.system.diskAddress  = address
        self.system.diskType     = diskData.type
        self.system.diskSubtype  = diskData.subtype

        if doBeep then computer.beep(1000, 0.02) end
        return true
    end

    if doBeep then
        computer.beep(1000, 0.20)
        os.sleep(0.10)
        computer.beep(1000, 0.20)
    end

    return false
end

function DiskDriveManager:forget()
    self.system.diskInserted = false
    self.system.diskAddress  = nil
    self.system.diskType     = nil
    self.system.diskSubtype  = nil
end

function DiskDriveManager:run()
    if not self.system.diskInserted then
        error("Disk drive: nothing to run")
    end
end

function DiskDriveManager:checkComponents()
    for address in pairs(component.list("filesystem")) do
        if self:check(address, false) then
            break
        end
    end
end

return DiskDriveManager