-- COS
local Object  = require "system.main.object"
local Desktop = require "system.desktop"
local SignUp  = require "system.auth.signUp"
local SignIn  = require "system.auth.signIn"
local Config  = require "system.configManager"
-- OOS
local computer  = require "computer"
local shell     = require "shell"
local process   = require "process"

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

function OS:checkConfigFiles()
    if (not self.config:exist("ui")) then
        self.config:create("ui", {
            desktop = {
                backgroundColor  = 0x282828
            },
            window = {
                backgroundColor  = 0x282828,
                frameColor       = 0x555547,
                textColor        = 0xa59c83,
                windowNameColor  = 0xa59c83,
                closeButtonColor = 0x555547
            },
            shortcut = {
                backgroundColor = 0x535353,
                textColor       = 0xa59c83,
                selectedBackgroundColor = 0x919191,
                selectedTextColor       = 0x282828,
            }
        })
    end

    if (not self.config:exist("startup")) then
        self.config:create("startup", {
            doFirstLaunchProcedure = true,
            isLocked = false
        })
    end

    if (not self.config:exist("user")) then
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

    if (self.config:get("startup", "doFirstLaunchProcedure")) then
        SignUp:new(_, {
            system = self,
        }):init()
    elseif (self.config:get("user", "password") ~= "") then
        SignIn:new(_, {
            system = self,
        }):init()
    end

    Desktop:new(_, {
        system = self
    }):init()
end

-- Todo: uncomment when release version will be ready
--process.info().data.signal = function(...)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--end

OS:new():init()