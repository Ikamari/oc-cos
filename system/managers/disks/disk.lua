-- InfOS
local Object = require "system.main.object"
local PopUp  = require "system.popup"

---@class Disk
---@field public system     OS
---@field public currentApp BasicApp
local Disk = Object:inherit({
    autorun            = true,
    runWhenLoggedIn    = true,
    runWhenNotLoggedIn = false,
    visibleInDesktop   = false
})

function Disk:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if not parameters.system then
        error("App must receive reference to system core as parameter")
    end

    properties.system = parameters.system
end

function Disk:showError(currentApp)
    local parameters = {
        windowName = "Ошибка",
        text = "Установленная дискета содержит данные неизвестного формата",
        type = "error",
        doConfirmButtonRender = true,
        doCloseButtonRender   = false,
        confirmButtonText     = "Ок",
        centeredText          = true,
    }
    if currentApp then
        currentApp:call(PopUp, parameters)
    else
        PopUp:new(_, parameters):init()
    end
end

function Disk:whenLoggedIn(currentApp) self:showError(currentApp) end

function Disk:whenNotLoggedIn(currentApp) end

function Disk:init(currentApp)
    if self.system.isLoggedIn and self.runWhenLoggedIn then
        self:whenLoggedIn(currentApp)
    elseif not self.system.isLoggedIn and self.runWhenNotLoggedIn then
        self:whenNotLoggedIn(currentApp)
    end
end

return Disk

