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

function OS:checkConfigFiles()
    if (not self.config:exist("ui")) then
        self.config:create("ui", {
            desktop = {
                backgroundColor = 0x282828
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
        print("Создан конфиг пользовательского интерфейса")
    else
        print("Конфиг пользовательского интерфейса присутствует")
    end
    if (self.doSlowStartup) then os.sleep(0.2) end

    if (not self.config:exist("startup")) then
        self.config:create("startup", {
            doFirstLaunchProcedure     = true,
            doLockedTerminalSimulation = false,
            doSlowStartup              = false
        })
        print("Создан конфиг запуска")
    else
        print("Конфиг запуска присутствует")
    end
    if (self.doSlowStartup) then os.sleep(0.2) end

    if (not self.config:exist("user")) then
        self.config:create("user", {
            username = "Пользователь",
            password = null
        })
        print("Создан конфиг пользователя")
    else
        print("Конфиг пользователя присутствует")
    end
end

-- Note: if something goes whong, try to redo initialization of "OS" and desktop

function OS:init()
    if (self.isRunning) then
        return false
    end
    self.isRunning = true
    self.doSlowStartup = self.config:exist("startup") and self.config:get("startup", "doSlowStartup") or true

    os.execute("clear")

    print("Начинается проверка конфиг файлов")
    if (self.doSlowStartup) then os.sleep(0.5) end
    self:checkConfigFiles()

    print("Начинается инициализация рабочего стола")
    if (self.doSlowStartup) then os.sleep(2) end

    (Desktop:new(_, {
        system = self
    })):init()
end

(OS:new()):init()


