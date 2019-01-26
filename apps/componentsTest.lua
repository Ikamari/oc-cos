--
-- Created by Ikamari, 19.01.2019 13:30
--

-- COS
local Window     = require "system.window"
local Button     = require "system.components.common.button"
local Switch     = require "system.components.common.switch"
local TextField  = require "system.components.common.textField"
local InputField = require "system.components.common.inputField"
-- OOS
local component = require "component"
local gpu       = component.gpu

local uiComponentsTest = Window:inherit({
    -- Properties
    windowName = "Тест UI компонентов"
    --
})

function uiComponentsTest:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    Window:constructor(properties, parameters)

    local testButton1 = Button:new(_, {
        parent = properties,
        label  = "Сделать фон окна красным",
        posX   = properties.contentX,
        posY   = properties.contentY,
        width  = 45,
        height = 1,
        onTouchCallback = function()
            properties.backgroundColor = 0xFF0000
            properties:render()
        end
    })
    properties.components[#properties.components + 1] = testButton1

    local testButton2 = Button:new(_, {
        parent = properties,
        label  = "Сделать фон окна зелёным",
        posX   = properties.contentX,
        posY   = properties.contentY + 3,
        width  = 45,
        height = 1,
        onTouchCallback = function()
            properties.backgroundColor = 0x00FF00
            properties:render()
        end
    })
    properties.components[#properties.components + 1] = testButton2

    local testButton3 = Button:new(_, {
        parent = properties,
        label  = "Сделать фон окна синим",
        posX   = properties.contentX,
        posY   = properties.contentY + 6,
        width  = 45,
        height = 1,
        onTouchCallback = function()
            properties.backgroundColor = 0x0000FF
            properties:render()
        end
    })
    properties.components[#properties.components + 1] = testButton3

    local testButton4 = Button:new(_, {
        parent = properties,
        label  = "Сделать фон окна рандомного цвета",
        posX   = properties.contentX,
        posY   = properties.contentY + 9,
        width  = 45,
        height = 1,
        onTouchCallback = function()
            math.randomseed(os.time())

            properties.backgroundColor = math.floor(math.random() * 16777215)
            properties:render()
        end
    })
    properties.components[#properties.components + 1] = testButton4

    local testTextField1 = TextField:new(_, {
        parent = properties,
        posX   = properties.contentX + 47,
        posY   = properties.contentY,
        width  = 25,
        height = 3,
        text   = "Текстовое поле, которое может в себя вместить 3 строки по 25 символов"
    })
    properties.components[#properties.components + 1] = testTextField1

    local testTextField2 = TextField:new(_, {
        parent = properties,
        posX   = properties.contentX + 74,
        posY   = properties.contentY,
        width  = 25,
        height = 3,
        text   = "Ещё одно текстовое поле, которое реагирует на переключатель ниже"
    })
    properties.components[#properties.components + 1] = testTextField2

    local testSwitch1 = Switch:new(_, {
        parent = properties,
        posX   = properties.contentX,
        posY   = properties.contentY + 12,
        width  = 45,
        height = 1,
        standalone = true
    })
    properties.components[#properties.components + 1] = testSwitch1

    local testSwitch2 = Switch:new(_, {
        parent = properties,
        posX   = properties.contentX + 47,
        posY   = properties.contentY + 12,
        width  = 45,
        height = 1,
        standalone = true,
        activeLabelBackgroundColor   = 0x00AA00,
        unactiveLabelBackgroundColor = 0xAA0000,
        doLabelRenderOnActive   = false,
        doLabelRenderOnUnactive = false,
        onTouchCallback         = function (state)
            testTextField2.textForegroundColor = state and 0x00AA00 or 0xAA0000
            properties:render()
        end
    })
    properties.components[#properties.components + 1] = testSwitch2

    local testInputField1 = InputField:new(_, {
        parent = properties,
        posX   = properties.contentX,
        posY   = properties.contentY + 18,
        width  = 45,
        height = 2,
        placeholder = "Введи сюда что-то"
    })
    properties.inputComponents[#properties.inputComponents + 1] = testInputField1
end

return uiComponentsTest