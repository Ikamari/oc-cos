-- COS
local constants  = require "system.constants"
local AuthForm   = require "system.auth.AuthForm"
local PopUp      = require "system.popup"
local Line       = require "system.components.common.line"
local Button     = require "system.components.common.button"
local TextField  = require "system.components.common.textField"
local LinedInputField = require "system.components.common.linedInputField"

local SignUp = AuthForm:inherit({})

function SignUp:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    AuthForm:constructor(properties, parameters)

    local greet = TextField:new(_, {
        parent = properties,
        posY   = properties.contentY + 14,
        width  = 26,
        height = 1,
        text   = "Добро пожаловать в InfOS!",
        centeredText = true,
        horizontallyCentered = true
    })
    properties.components["greetTextField"] = greet

    local line = Line:new(_, {
        parent = properties,
        orientation = "horizontal",
        posY   = properties.contentY + 15,
        width  = 87,
        horizontallyCentered = true
    })
    properties.components[#properties.components + 1] = line

    local info = TextField:new(_, {
        parent = properties,
        posY = properties.contentY + 16,
        width = 87,
        height = 3,
        text = "В связи с тем, что это первый запуск системы, необходимо, чтобы Вы указали своё имя или название этого компьютера. Также в целях безопасности рекомендуется указать пароль.",
        horizontallyCentered = true,
        centeredText = true
    })
    properties.components["infoTextField"] = info

    local nameField = LinedInputField:new(_, {
        parent = properties,
        posX = -1,
        posY = properties.contentY + 21,
        width = 32,
        height = 1,
        placeholder = "Имя",
        horizontallyCentered = true
    })
    properties.inputComponents["nameInputField"] = nameField

    local passwordField = LinedInputField:new(_, {
        parent = properties,
        posX   = -1,
        posY   = properties.contentY + 24,
        width  = 32,
        height = 1,
        placeholder = "Пароль (максимум 8 символов)",
        maxLineLength = 8,
        horizontallyCentered = true,
        hiddenText = true,
        filter = "[\33-\122]"
    })
    properties.inputComponents["passwordInputField"] = passwordField

    local passwordRepeatField = LinedInputField:new(_, {
        parent = properties,
        posX = -1,
        posY = properties.contentY + 27,
        width = 32,
        height = 1,
        placeholder = "Повтор пароля",
        maxLineLength = 8,
        horizontallyCentered = true,
        hiddenText = true,
        filter = "[\33-\122]"
    })
    properties.inputComponents["passwordRepeatInputField"] = passwordRepeatField

    local acceptButton = Button:new(_, {
        parent = properties,
        text   = "Принять данные и продолжить",
        posY   = properties.contentY + 31,
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
        posY   = properties.contentY + 34,
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

function SignUp:submit()
    local name           = self.inputComponents["nameInputField"].lines[0]
    local password       = self.inputComponents["passwordInputField"].lines[0]
    local passwordRepeat = self.inputComponents["passwordRepeatInputField"].lines[0]

    if (name == "") then
        self.components["errorTextField"].isVisible = true
        self.components["errorTextField"]:updateText("Поле \"Имя\" должно быть заполнено")
        self:render()
        return
    end

    if (password ~= "" or passwordRepeat ~= "") then
        if (passwordRepeat == "") then
            self.components["errorTextField"].isVisible = true
            self.components["errorTextField"]:updateText("Поле \"Повтор пароля\" должно быть заполнено")
            self:render()
            return
        end
        if (password ~= passwordRepeat) then
            self.components["errorTextField"].isVisible = true
            self.components["errorTextField"]:updateText("Пароли не совпадают")
            self:render()
            return
        end
    else
        self:cancelEvents()
        self:renderBackground();
        if PopUp:new(_, {
            windowName = "Подтверждение",
            text = "Вы уверены в том, что не хотите устанавливать пароль?",
            centeredText = true,
            type = "warning",
            doConfirmButtonRender = true,
            doDenyButtonRender    = true,
            doCloseButtonRender   = false
        }):init() == false then
            self:render()
            return
        end
    end

    self:renderBackground();
    PopUp:new(_, {
        windowName = "Подсказка",
        text = "Новый пароль всегда можно будет указать в настройках",
        centeredText = true,
        type = "default",
        doConfirmButtonRender = true,
        confirmButtonText     = "Ок",
        doCloseButtonRender   = false
    }):init()

    self.system.config:setValues("user", {
        name     = name,
        password = password
    })
    self.system.config:setValue("startup", "doFirstLaunchProcedure", false)
    self:terminate()
end

return SignUp