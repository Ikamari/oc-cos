--
-- Created by Ikamari, 14.12.2018 23:34
--

-- COS
local Object  = require "system.main.object"
local Desktop = require "system.desktop"
local Config  = require "system.utillity.config"
-- OOS
local computer  = require "computer"
local shell     = require "shell"
local process   = require "process"

-- Todo: uncomment when release version will be ready
--process.info().data.signal = function(...)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--end

local OS = Object:inherit({
    isRunning = false
})

function OS:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.rootPath = shell.resolve(process.info().path):gsub("(%S+.)os", "%1")

    local config = Config:new(_, {
        rootPath = properties.rootPath
    })
    properties.config = config
end

function OS:run()
    if (self.isRunning) then
        return false
    end
    self.isRunning = true

    local desktop = Desktop:new(_, {
        system = self
    })
    desktop:init()
end

local system = OS:new()
system:run()

