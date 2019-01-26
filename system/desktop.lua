--
-- Created by Ikamari, 14.12.2018 23:35
--

-- COS
local Window        = require "system.window"
local ClickableZone = require "system.components.clickableZone"
local Shortcut      = require "system.components.desktop.shortcut"
local PopUp         = require "system.popup"
local constants     = require "system.constants"
-- COS Apps
local Paint          = require "apps.paint"
local ComponentsTest = require "apps.componentsTest"
-- OOS
local computer      = require "computer"
local component     = require "component"
local gpu           = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

local Desktop = Window:inherit({
    -- Properties
    doFrameRender       = false,
    doBackgroundRender  = true,
    doWindowNameRender  = false,
    doCloseButtonRender = false,

    autoSize = false
    --
})

function Desktop:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    Window:constructor(properties, parameters)

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
                text       = "Ура! Наконец-то я могу вместить себе больше одной строчки текста! Долой этот чёртов хардкод! (Теперь бы ещё поддержку \"\\n\" и было бы вообще шикарно)",
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
                local app = callbackParameters.app:new(_, callbackParameters.appParameters)
                app:init()

                parent:render()
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