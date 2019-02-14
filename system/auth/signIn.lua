-- InfOS
local constants  = require "system.constants"
local AuthForm   = require "system.auth.AuthForm"
-- Components
local Line       = require "system.components.common.line"
local Button     = require "system.components.common.button"
local TextField  = require "system.components.common.textField"
local LinedInputField = require "system.components.common.linedInputField"

---@class SignIn : AuthForm
local SignIn = AuthForm:inherit({})

---@param properties SignIn
function SignIn:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    AuthForm:constructor(properties, parameters)

    properties:addComponent(TextField, {
        posY   = properties.contentY + 17,
        width  = 26,
        height = 1,
        text   = "Авторизация",
        centeredText = true,
        horizontallyCentered = true
    }, properties, "greetTextField")

    properties:addComponent(Line, {
        orientation = "horizontal",
        posY   = properties.contentY + 18,
        width  = 87,
        horizontallyCentered = true
    }, properties)

    properties:addComponent(TextField, {
        posY   = properties.contentY + 19,
        width  = 32,
        height = 1,
        text   = properties.system.config:get("user", "name"),
        centeredText = true,
        horizontallyCentered = true
    }, properties, "name")

    properties:addComponent(LinedInputField, {
        posX   = -1,
        posY   = properties.contentY + 21,
        width  = 32,
        height = 1,
        placeholder = "Пароль",
        maxLineLength = 8,
        horizontallyCentered = true,
        hiddenText = true,
        filter = "[\33-\122]"
    }, properties, "passwordInputField")

    properties:addComponent(Button, {
        text   = "Войти",
        posY   = properties.contentY + 25,
        width  = 34,
        height = 1,
        horizontallyCentered = true,
        onTouchCallback = function()
    properties:submit()
    end
    }, properties, "acceptButton")

    properties:addComponent(TextField, {
        posY   = properties.contentY + 28,
        width  = 50,
        height = 1,
        text   = "",
        centeredText = true,
        horizontallyCentered = true,
        isVisible = false,
        textForegroundColor = constants.errorTextColor
    }, properties, "errorTextField")
end

function SignIn:submit()
    local password      = self.inputComponents["passwordInputField"].lines[1]
    local validPassword = self.system.config:get("user", "password")

    if (password == validPassword) then
        self.system.isLoggedIn = true
        self:terminate()
    else
        self.components["errorTextField"].isVisible = true
        self.components["errorTextField"]:updateText("В доступе отказано. Введён неверный пароль")
        self:render()
        return
    end
end

return SignIn