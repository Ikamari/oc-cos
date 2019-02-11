-- InfOS
local Object  = require "system.main.object"
local Desktop = require "system.desktop"
local SignUp  = require "system.auth.signUp"
local SignIn  = require "system.auth.signIn"

local File    = require "system.managers.fileManager"
local Config  = require "system.managers.configManager"
local Storage = require "system.managers.storageManager"
local Drive   = require "system.managers.diskDriveManager"

local BSOD    = require "system.bsod"
-- OpenOS
local computer  = require "computer"
local shell     = require "shell"
local process   = require "process"

---@class OS
---@field public config  ConfigManager
---@field public drive   DiskDriveManager
---@field public storage StorageManager
---@field public file    FileManager
local OS = Object:inherit({
    version    = "0.6.0",
    isRunning  = false,
    isLoggedIn = false,
    isUnrecoverable = false
})

function OS:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.rootPath = shell.resolve(process.info().path):gsub("(%S+.)os", "%1")

    local file = File:new(_, {
        system = properties
    })
    properties.file = file

    local config = Config:new(_, {
        system   = properties,
        rootPath = properties.rootPath
    })
    properties.config = config

    local storage = Storage:new(_, {
        system   = properties,
        rootPath = properties.rootPath
    })
    properties.storage = storage

    local drive = Drive:new(_, {
        system = properties,
        rootPath = properties.rootPath
    })
    properties.drive = drive
end

function OS:checkConfigFiles()
    --if (not self.config:exists("ui")) then
    --    self.config:create("ui", {
    --        desktop = {
    --            backgroundColor  = 0x282828
    --        },
    --        window = {
    --            backgroundColor  = 0x282828,
    --            frameColor       = 0x555547,
    --            textColor        = 0xa59c83,
    --            windowNameColor  = 0xa59c83,
    --            closeButtonColor = 0x555547
    --        },
    --        shortcut = {
    --            backgroundColor = 0x535353,
    --            textColor       = 0xa59c83,
    --            selectedBackgroundColor = 0x919191,
    --            selectedTextColor       = 0x282828,
    --        }
    --    })
    --end

    if (not self.config:exists("startup")) then
        self.config:create("startup", {
            doFirstLaunchProcedure = true,
            isLocked = false
        })
    end

    if (not self.config:exists("user")) then
        self.config:create("user", {
            name     = "Пользователь",
            password = ""
        })
    end
end

function OS:init()
    if (self.isRunning) then
        return false
    end
    self.isRunning = true
    self:checkConfigFiles()

    repeat
        local status, error = xpcall(function()
            self.drive:checkComponents()
            if (not self.isLoggedIn) then
                if (self.config:get("startup", "doFirstLaunchProcedure")) then
                    SignUp:new(_, {
                        system = self,
                    }):run()
                elseif (self.config:get("user", "password") ~= "") then
                    SignIn:new(_, {
                        system = self,
                    }):run()
                else
                    self.isLoggedIn = true
                end
            end

            Desktop:new(_, {
                system = self
            }):run()
        end, debug.traceback)
        if (not status) then
            BSOD:new(_, {
                system = self,
                error  = error,
                isUnrecoverable = self.isUnrecoverable
            }):run()
            status = true
            -- Todo: remove this part of code when release version will be ready
            self.isRunning = false
            os.execute("clear")
        end
    until not self.isRunning
end

-- Todo: uncomment when release version will be ready
--process.info().data.signal = function(...)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--end

OS:new():init()