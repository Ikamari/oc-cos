-- COS
local constants  = require "system.constants"
local AuthForm   = require "system.auth.AuthForm"
local Line       = require "system.components.common.line"
local Button     = require "system.components.common.button"
local TextField  = require "system.components.common.textField"
local LinedInputField = require "system.components.common.linedInputField"

---@class SignIn : AuthForm
local SignIn = AuthForm:inherit({})

function SignIn:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    AuthForm:constructor(properties, parameters)

    local greet = TextField:new(_, {
        parent = properties,
        posY   = properties.contentY + 17,
        width  = 26,
        height = 1,
        text   = "Авторизация",
        centeredText = true,
        horizontallyCentered = true
    })
    properties.components["greetTextField"] = greet

    local line = Line:new(_, {
        parent = properties,
        orientation = "horizontal",
        posY   = properties.contentY + 18,
        width  = 87,
        horizontallyCentered = true
    })
    properties.components[#properties.components + 1] = line

    local name = TextField:new(_, {
        parent = properties,
        posY = properties.contentY + 19,
        width = 32,
        height = 1,
        text = properties.system.config:get("user", "name"),
        centeredText = true,
        horizontallyCentered = true
    })
    properties.components["name"] = name

    local passwordField = LinedInputField:new(_, {
        parent = properties,
        posX   = -1,
        posY   = properties.contentY + 21,
        width  = 32,
        height = 1,
        placeholder = "Пароль",
        maxLineLength = 8,
        horizontallyCentered = true,
        hiddenText = true,
        filter = "[\33-\122]"
    })
    properties.inputComponents["passwordInputField"] = passwordField

    local acceptButton = Button:new(_, {
        parent = properties,
        text   = "Войти",
        posY   = properties.contentY + 25,
        width  = 34,
        height = 1,
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:submit()
        end
    })
    properties.components["acceptButton"] = acceptButton

    local errorTextField = TextField:new(_, {
        parent = properties,
        posY   = properties.contentY + 28,
        width  = 50,
        height = 1,
        text   = "",
        centeredText = true,
        horizontallyCentered = true,
        isVisible = false,
        textForegroundColor = constants.errorStringColor
    })
    properties.components["errorTextField"] = errorTextField
end

function SignIn:submit()
    local password      = self.inputComponents["passwordInputField"].lines[0]
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