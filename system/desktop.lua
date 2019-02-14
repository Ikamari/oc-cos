-- InfOS
local BasicApp       = require "system.app"
local PopUp          = require "system.popup"
local Shortcut       = require "system.components.desktop.shortcut"
local constants      = require "system.constants"
local icons          = require "system.icons"
-- InfOS Apps
local Paint          = require "apps.paint"
local ComponentsTest = require "apps.componentsTest"
local TextEditor     = require "apps.textEditor"
local Settings       = require "apps.settings"
-- OpenOS
local computer       = require "computer"

---@class Desktop : BasicApp
local Desktop = BasicApp:inherit({
    doFrameRender       = false,
    doBackgroundRender  = true,
    doWindowNameRender  = false,
    doCloseButtonRender = false,

    autoSize      = false,

    currentRow      = 1,
    currentColumn   = 1,
    shortcutsPerRow = 2,
    shortcutRows    = 2
})

---@param properties Desktop
function Desktop:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)

    -- Define shortcuts
    properties.shortcutStartX = ((properties.windowWidth / 2) - constants.shortcutWidth) - 1
    properties.shortcutStartY = properties.windowY + 9
    properties.nextShortcutX  = properties.shortcutStartX
    properties.nextShortcutY  = properties.shortcutStartY

    -- Hardcoded paint shortcut
    local shortcuts = {
        {
            app = nil,
        },
        {
            app = TextEditor,
        },
        {
            app = Settings,
        },
        {
            executable = PopUp,
            parameters = {
                windowName = "Выключение",
                text = "Что Вы желаете сделать?",
                centeredText = true,
                doConfirmButtonRender = true,
                doDenyButtonRender    = true,
                doCloseButtonRender   = true,
                confirmButtonText     = "Завершить работу",
                denyButtonText        = "Перезагрузить компьютер",
                onConfirmCallback     = function ()
                    computer.shutdown(false)
                end,
                onDenyCallback        = function()
                    computer.shutdown(true)
                end
            },
            text = "Выключение",
            icon = icons.exit
        }
    }

    for _, shortcutData in pairs(shortcuts) do
        properties:addComponent(Shortcut, {
            posX = properties.nextShortcutX,
            posY = properties.nextShortcutY,
            app  = shortcutData.app,
            executable = shortcutData.executable,
            parameters = shortcutData.parameters,
            text = shortcutData.text,
            icon = shortcutData.icon
        }, properties)

        -- todo: needs to be finished
        if properties.currentColumn + 1 <= properties.shortcutsPerRow then
            properties.currentColumn = properties.currentColumn + 1
            properties.nextShortcutX = properties.nextShortcutX + constants.shortcutWidth + 2
        elseif properties.currentRow + 1 <= properties.shortcutRows then
            properties.currentColumn = 1
            properties.currentRow    = properties.currentRow + 1
            properties.nextShortcutX = properties.shortcutStartX
            properties.nextShortcutY = properties.nextShortcutY + constants.shortcutHeight + 1
        else
            break
        end
    end
end

function Desktop:processInterruptEvent()
    computer.beep(750, 0.02)
    computer.beep(750, 0.02)
    computer.beep(750, 0.02)
end

return Desktop