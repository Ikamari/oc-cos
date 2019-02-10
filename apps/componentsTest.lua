-- InfOS
local BasicApp     = require "system.app"
-- Components
local Button       = require "system.components.common.button"
local Switch       = require "system.components.common.switch"
local TextField    = require "system.components.common.textField"
local LinedInputField = require "system.components.common.linedInputField"
-- OpenOS
local component = require "component"
local gpu       = component.gpu

---@class UIComponentsTest : BasicApp
local UIComponentsTest = BasicApp:inherit({
    windowName = "Тест UI компонентов"
})

---@param properties UIComponentsTest
function UIComponentsTest:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)

    properties:addComponent(Button, {
        text  = "Сделать фон окна красным",
        posX   = properties.contentX,
        posY   = properties.contentY,
        width  = 45,
        height = 1,
        onTouchCallback = function()
            properties.backgroundColor = 0xFF0000
            properties:render()
        end
    }, properties)

    properties:addComponent(Button, {
        text  = "Сделать фон окна зелёным",
        posX   = properties.contentX,
        posY   = properties.contentY + 3,
        width  = 45,
        height = 1,
        onTouchCallback = function()
            properties.backgroundColor = 0x00FF00
            properties:render()
        end
    }, properties)

    properties:addComponent(Button, {
        text  = "Сделать фон окна синим",
        posX   = properties.contentX,
        posY   = properties.contentY + 6,
        width  = 45,
        height = 1,
        onTouchCallback = function()
            properties.backgroundColor = 0x0000FF
            properties:render()
        end
    }, properties)

    properties:addComponent(Button, {
        text  = "Сделать фон окна рандомного цвета",
        posX   = properties.contentX,
        posY   = properties.contentY + 9,
        width  = 45,
        height = 1,
        onTouchCallback = function()
            math.randomseed(os.time())
            properties.backgroundColor = math.floor(math.random() * 16777215)
            properties:render()
        end
    }, properties)

    properties:addComponent(TextField, {
        posX   = properties.contentX + 47,
        posY   = properties.contentY,
        width  = 25,
        height = 3,
        text   = "Текстовое поле, которое может в себя вместить 3 строки по 25 символов"
    }, properties)

    local switchableTextField = properties:addComponent(TextField, {
        posX   = properties.contentX + 74,
        posY   = properties.contentY,
        width  = 25,
        height = 3,
        text   = "Ещё одно текстовое поле, которое реагирует на переключатель ниже"
    }, properties)

    properties:addComponent(Switch, {
        posX   = properties.contentX,
        posY   = properties.contentY + 12,
        width  = 45,
        height = 1,
        standalone = true
    }, properties)

    properties:addComponent(Switch, {
        posX   = properties.contentX + 47,
        posY   = properties.contentY + 12,
        width  = 45,
        height = 1,
        standalone = true,
        activeTextBackgroundColor   = 0x00AA00,
        unactiveTextBackgroundColor = 0xAA0000,
        doTextRenderOnActive   = false,
        doTextRenderOnUnactive = false,
        onTouchCallback         = function (state)
            switchableTextField.textForegroundColor = state and 0x00AA00 or 0xAA0000
            properties:render()
        end
    }, properties)

    properties:addComponent(LinedInputField, {
        posX   = properties.contentX,
        posY   = properties.contentY + 18,
        width  = 45,
        height = 2,
        placeholder = "Введи сюда что-то",
        horizontallyCentered = true
    }, properties)
end

return UIComponentsTest