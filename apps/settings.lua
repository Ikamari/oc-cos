-- InfOS
local BasicApp  = require "system.app"
local PopUp     = require "system.popup"
local constants = require "system.constants"
local icons     = require "system.icons"
-- Components
local Button          = require "system.components.common.button"
local Switch          = require "system.components.common.switch"
local TextField       = require "system.components.common.textField"
local LinedInputField = require "system.components.common.linedInputField"

---@class Settings : BasicApp
local Settings = BasicApp:inherit({
    windowName = "Настройки",
    icon       = icons.settings
})

---@param properties Settings
function Settings:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)

    properties:addComponent(TextField, {
        posX   = properties.contentX,
        posY   = properties.contentY,
        width  = 42,
        height = 1,
        text   = "Имя пользователя / компьютера",
        centeredText = true,
    }, properties, "name_label")

    properties:addComponent(LinedInputField, {
        posX   = properties.contentX,
        posY   = properties.contentY + 1,
        width  = 40,
        height = 1,
        maxLineLength = 30,
        placeholder  = "Новое имя",
        initialLines = {
            properties.system.config:get("user", "name")
        }
    }, properties, "name_input")

    properties:addComponent(Button, {
        posX   = properties.contentX,
        posY   = properties.contentY + 4,
        width  = 42,
        height = 1,
        text   = "Изменить имя",
        onTouchCallback = function()
            properties:updateName()
        end
    }, properties, "update_name_button")

    properties:addComponent(TextField, {
        posX   = properties.contentX,
        posY   = properties.contentY + 6,
        width  = 42,
        height = 1,
        text   = "",
        isVisible = false,
        centeredText = true,
        doBackgroundRender = true
    }, properties, "name_result")

    properties:addComponent(TextField, {
        posX   = properties.contentX,
        posY   = properties.contentY + 8,
        width  = 42,
        height = 1,
        text   = "Безопасность",
        centeredText = true
    }, properties, "password_label")

    properties:addComponent(LinedInputField, {
        posX   = properties.contentX,
        posY   = properties.contentY + 9,
        width  = 40,
        height = 1,
        placeholder = "Текущий пароль",
        maxLineLength = 8,
        hiddenText = true,
        filter = "[\33-\122]"
    }, properties, "old_password_input")

    properties:addComponent(LinedInputField, {
        posX   = properties.contentX,
        posY   = properties.contentY + 12,
        width  = 40,
        height = 1,
        placeholder = "Новый пароль (макс. 8 символов)",
        maxLineLength = 8,
        hiddenText = true,
        filter = "[\33-\122]"
    }, properties, "new_password_input")

    properties:addComponent(LinedInputField, {
        posX   = properties.contentX,
        posY   = properties.contentY + 15,
        width  = 40,
        height = 1,
        placeholder = "Подтверждение пароля",
        maxLineLength = 8,
        hiddenText = true,
        filter = "[\33-\122]"
    }, properties, "new_password_repeat_input")

    properties:addComponent(Switch, {
        posX   = properties.contentX,
        posY   = properties.contentY + 19,
        width  = 42,
        height = 1,
        standalone   = true,
        defaultState = true,
        activeText   = "Показать пароль",
        unactiveText = "Скрыть пароль",
        onTouchCallback = function (state)
            properties:switchPasswordVisibility(state)
        end
    }, properties, "password_visibility_switch")

    properties:addComponent(Button, {
        posX   = properties.contentX,
        posY   = properties.contentY + 21,
        width  = 42,
        height = 1,
        text   = "Установить новый пароль",
        onTouchCallback = function()
            properties:updatePassword()
        end
    }, properties, "update_password_button")

    properties:addComponent(Button, {
        posX   = properties.contentX,
        posY   = properties.contentY + 23,
        width  = 42,
        height = 1,
        text   = "Сбросить пароль",
        onTouchCallback = function()
            properties:resetPassword()
        end
    }, properties, "reset_password_button")

    properties:addComponent(TextField, {
        posX   = properties.contentX,
        posY   = properties.contentY + 25,
        width  = 42,
        height = 2,
        text   = "",
        isVisible = false,
        centeredText = true,
        doBackgroundRender = true
    }, properties, "password_result")
end

---@param Component TextField
function Settings:showResult(Component, isSuccess, message)
    Component.isVisible = true
    Component.textForegroundColor = constants[isSuccess and "successTextColor" or "errorTextColor"]
    Component:updateText(message)
end

function Settings:switchPasswordVisibility(state)
    self:getComponent("old_password_input").hiddenText = state
    self:getComponent("new_password_input").hiddenText = state
    self:getComponent("new_password_repeat_input").hiddenText = state
    self:render()
end

function Settings:validateOldPassword()
    local oldPassword      = self:getComponent("old_password_input").lines[0]
    local validOldPassword = self.system.config:get("user", "password")

    if validOldPassword == "" then
        return -1
    end

    if oldPassword == "" then
        return -2
    end

    return oldPassword == validOldPassword and 1 or 0
end

function Settings:updatePassword()
    local newPassword = self:getComponent("new_password_input").lines[0]
    local repeatOfNewPassword = self:getComponent("new_password_repeat_input").lines[0]

    if newPassword == "" then
        self:showResult(self:getComponent("password_result"), false, "Поле \"Новый пароль\" должно быть заполнено")
        return false
    elseif repeatOfNewPassword == "" then
        self:showResult(self:getComponent("password_result"), false, "Поле \"Подтверждение пароля\" должно быть заполнено")
        return false
    elseif newPassword ~= repeatOfNewPassword then
        self:showResult(self:getComponent("password_result"), false, "Пароль и его подтверждение не совпадают")
        return false
    end

    local result = self:validateOldPassword()
    if result == 0 then
        self:showResult(self:getComponent("password_result"), false, "Введён неверный текущий пароль")
        return false
    elseif result == -2 then
        self:showResult(self:getComponent("password_result"), false, "Поле \"Текущий пароль\" должно быть заполнено")
        return false
    end

    self.system.config:setValue("user", "password", newPassword)
    self:showResult(self:getComponent("password_result"), true, "Новый пароль успешно установлен")
    self:getComponent("new_password_input"):updateLines({""})
    self:getComponent("new_password_repeat_input"):updateLines({""})
    return true
end

function Settings:resetPassword()
    local result = self:validateOldPassword()
    if result == 0 then
        self:showResult(self:getComponent("password_result"), false, "Введён неверный текущий пароль")
        return false
    elseif result == -1 then
        self:showResult(self:getComponent("password_result"), false, "Пароль не установлен")
        return false
    elseif result == -2 then
        self:showResult(self:getComponent("password_result"), false, "Поле \"Текущий пароль\" должно быть заполнено")
        return false
    end

    local decision = self:call(PopUp, {
        windowName = "Подтверждение",
        text = "Без пароля компьютер станет доступен любому пользователю.\nВы уверены в том, что хотите сделать сброс?",
        centeredText = true,
        type = "warning",
        doConfirmButtonRender = true,
        doDenyButtonRender    = true,
        doCloseButtonRender   = false
    })

    if not decision then
        self:showResult(self:getComponent("password_result"), true, "")
        return false
    end

    self.system.config:setValue("user", "password", "")
    self:showResult(self:getComponent("password_result"), true, "Пароль успешно сброшен")
    self:getComponent("old_password_input"):updateLines({""})
    return true
end

function Settings:updateName()
    local newName     = self:getComponent("name_input").lines[0]
    local currentName = self.system.config:get("user", "name")
    if newName ~= currentName and newName ~= "" then
        self.system.config:setValue("user", "name", newName)
        self:showResult(self:getComponent("name_result"), true, "Имя успешно изменено")
        return true
    elseif newName == currentName then
        self:showResult(self:getComponent("name_result"), true, "")
        return false
    end

    self:showResult(self:getComponent("name_result"), false, "Поле \"Новое имя\" должно быть заполнено")
    return false
end

return Settings