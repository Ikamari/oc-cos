-- InfOS
local BasicApp      = require "system.app"
local ClickableZone = require "system.components.clickableZone"
local Shortcut      = require "system.components.desktop.shortcut"
local PopUp         = require "system.popup"
local constants     = require "system.constants"
-- InfOS Apps
local Paint          = require "apps.paint"
local ComponentsTest = require "apps.componentsTest"
local Settings       = require "apps.settings"
-- OpenOS
local computer      = require "computer"
local component     = require "component"
local gpu           = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

---@class Desktop : BasicApp
local Desktop = BasicApp:inherit({
    -- Properties
    doFrameRender       = false,
    doBackgroundRender  = true,
    doWindowNameRender  = false,
    doCloseButtonRender = false,

    autoSize = false
    --
})

---@param properties Desktop
function Desktop:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)

    -- Define shortcuts
    properties.nextShortcutX = properties.contentX
    properties.nextShortcutY = properties.contentY
    properties.shortcuts = {}

    -- Hardcoded paint shortcut
    local shortcuts = {
        {
            app = Paint,
            label = "Рисовалка",
            parameters = {
                windowX = properties.contentX,
                windowY = properties.contentY,
                system  = properties.system
            }
        },
        {
            app = ComponentsTest,
            label = "UI тест",
            parameters = {
                windowX = properties.contentX,
                windowY = properties.contentY,
                system  = properties.system
            }
        },
        {
            app = PopUp,
            label = "Уведомление",
            parameters = {
                windowName = "Уведомление",
                text       = "Ура! Наконец-то я могу вместить себе больше одной строчки текста! Долой этот чёртов хардкод!",
                type       = "default"
            }
        },
        {
            app = PopUp,
            label = "Предупреждение",
            parameters = {
                windowName = "Предупреждение",
                text       = "?!",
                type       = "warning"
            }
        },
        {
            app = PopUp,
            label = "Ошибка",
            parameters = {
                windowName = "Ошибка",
                text       = "All your base are belong to us",
                type       = "error"
            }
        },
        {
            app = PopUp,
            label = "PopUp + Btns",
            parameters = {
                windowName = "Уведомление",
                text       = "Хочешь прикол?",
                type       = "default",
                doConfirmButtonRender = true,
                doCloseButtonRender   = false,
                doProcessInterruption = false,
                confirmButtonText     = "Ага!",
                centeredText          = true,
                onConfirmCallback     = function()
                    error("Это ты во всём виноват!")
                end
            }
        },
        {
            app = Settings,
            label = "Настройки",
            parameters = {
                windowX = properties.contentX,
                windowY = properties.contentY,
                system  = properties.system
            }
        }
    }

    for key, shortcut in pairs(shortcuts) do
        properties:addShortcut(properties, shortcut.label, shortcut.app, shortcut.parameters)
    end
end

function Desktop:addShortcut(properties, label, App, appParameters)
    properties.shortcuts[#properties.shortcuts + 1] = Shortcut:new(_, {
        posX  = properties.nextShortcutX,
        posY  = properties.nextShortcutY,
        label = label
    })

    properties.clickableZones[#properties.clickableZones + 1] = ClickableZone:new(_, {
        x      = properties.nextShortcutX,
        y      = properties.nextShortcutY,
        width  = constants.shortcutWidth,
        height = constants.shortcutHeight,
        type   = "zone",
        parent = properties,
        callback = function (parent, callbackParameters, parameters)
            if callbackParameters.shortcut.isSelected then
                callbackParameters.shortcut:switchSelectedState()
                parent:call(callbackParameters.app, callbackParameters.appParameters)
            else
                callbackParameters.shortcut:switchSelectedState()
                callbackParameters.shortcut:render()
            end
        end,
        onFailCallback = function (parent, callbackParameters, parameters)
            if callbackParameters.shortcut.isSelected then
                callbackParameters.shortcut:switchSelectedState()
                parent:renderContent()
            end
        end,
        callbackParameters = {
            shortcut      = properties.shortcuts[#properties.shortcuts],
            app           = App,
            appParameters = appParameters
        }
    })

    properties.nextShortcutX = properties.nextShortcutX + constants.shortcutWidth + 1

    local maxNextShortcutX = properties.contentX + properties.contentWidth - 1 - constants.shortcutWidth
    if properties.nextShortcutX > maxNextShortcutX then
        properties.nextShortcutX = 0
        properties.nextShortcutY = properties.nextShortcutY + constants.shortcutHeight + 1
    end
end

function Desktop:renderShortcuts()
    for key, shortcut in pairs(self.shortcuts) do
        shortcut:render()
    end
end

function Desktop:renderContent()
    self:renderShortcuts()
end

function Desktop:processInterruptEvent()
    computer.beep(750, 0.02)
    computer.beep(750, 0.02)
    computer.beep(750, 0.02)
end

return Desktop