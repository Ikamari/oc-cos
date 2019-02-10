-- InfOS
local Object  = require "system.main.object"
local Disk    = require "system.managers.disks.disk"
-- OpenOS
local computer   = require "computer"
local component  = require "component"

---@class DiskDriveManager
---You must initialize it before use
---@field public system OS
---@field public disk   Disk
local DiskDriveManager = Object:inherit({
    initialized = false,

    diskInserted = false,
    diskAddress  = nil,
    diskType     = nil,
    disk         = nil
})

function DiskDriveManager:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.system           = parameters.system
    properties.instructionsPath = parameters.rootPath .. "system/managers/disks/"
    properties.initialized      = true
end

--[[
    instruction.dat structure:
    {
        type - type of "data" inserted floppy "has" (hack tool, software installer, etc)
    }
]]--

function DiskDriveManager:hasInstructionFile(address)
    return self.system.file:exists("/mnt/" .. address:sub(0, 3) .. "/instruction.dat")
end

function DiskDriveManager:check(address, doBeep, currentApp)
    if type(address) ~= "string" then
        error("Address must be specified")
    end

    local instruction
    local instructionInfo

    local shortAddress = address:sub(0, 3)
    local instructionInfoPath = "/mnt/" .. shortAddress .. "/instruction.dat"

    -- Check whether disk has file with info about instruction
    if self.system.file:exists(instructionInfoPath) then
        -- Unserialize data of instruction file
        instructionInfo = self.system.file:read(instructionInfoPath)
        -- Check whether disk has valid instruction type
        local instructionPath = self.instructionsPath .. instructionInfo.type .. ".lua"
        if self.system.file:exists(instructionPath) then
            instruction = require("system.managers.disks." .. instructionInfo.type)
        end
    end

    self.diskInserted     = true
    self.diskShortAddress = shortAddress
    self.diskAddress      = address

    if instruction then
        self.diskType = instructionInfo.type
        self.disk     = instruction:new(_, { system = self.system })

        if doBeep then computer.beep(1000, 0.02) end
    else
        self.diskType = "unknown"
        self.disk     = Disk:new(_, { system = self.system })

        if doBeep then
            computer.beep(1000, 0.20)
            os.sleep(0.10)
            computer.beep(1000, 0.20)
        end
    end

    return self.disk.autorun
end

function DiskDriveManager:forget()
    self.diskInserted     = false
    self.diskShortAddress = nil
    self.diskAddress      = nil
    self.diskType         = nil
    self.disk             = nil
end

function DiskDriveManager:run(currentApp)
    if not self.diskInserted then
        error("Disk drive: nothing to run")
    end
    self.disk:init(currentApp)
end

function DiskDriveManager:checkComponents()
    for address in pairs(component.list("filesystem")) do
        if self:hasInstructionFile(address) then
            if self:check(address, false) then
                self:run()
                break
            end
        end
    end
end

return DiskDriveManager