-- COS
local BasicApp     = require "system.app"
local Line         = require "system.components.common.line"
local TextField    = require "system.components.common.textField"
local StringHelper = require "system.helpers.stringHelper"
-- OOS
local computer = require "computer"

---@class BSOD : BasicApp
local BSOD = BasicApp:inherit({
    -- Properties
    doFrameRender       = false,
    doBackgroundRender  = true,
    doWindowNameRender  = false,
    doCloseButtonRender = false,

    autoSize = false,
    contentIndent = 0,

    foregroundColor = 0xa59c83,
    backgroundColor = 0x0000EE
    --
})

function BSOD:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)
    properties.isUnrecoverable = parameters.isUnrecoverable

    local title = "InfOS v" .. properties.system.version
    local titleTextField = TextField:new(_, {
        parent = properties,
        posY   = properties.contentY + 4,
        width  = StringHelper:getLength(title),
        height = 1,
        text   = title,
        textForegroundColor = properties.backgroundColor,
        textBackgroundColor = properties.foregroundColor,
        centeredText = true,
        horizontallyCentered = true
    })
    properties.components["title"] = titleTextField

    local errorCode     = string.upper(string.format("%x", 110 + math.floor(math.random() * 100)))
    local errorAddress  = string.upper(string.format("%x", 1000000000 + math.floor(math.random() * 9000000000)))
    local solution = parameters.isUnrecoverable and ". Для предотвращения проблем необходим перезапуск." or ". Проблемная часть памяти будет выгружена."
    local info = TextField:new(_, {
        parent = properties,
        posY   = properties.contentY + 6,
        width  = 120,
        height = 1,
        text   = "Произошла неустранимая ошибка " .. errorCode .. " по адресу " .. "0x0" .. errorAddress .. solution,
        centeredText = true,
        horizontallyCentered = true
    })
    properties.components["info"] = info

    if not parameters.isUnrecoverable then
        local errorTextLine = TextField:new(_, {
            parent = properties,
            posY   = properties.contentY + 10,
            width  = 120,
            height = 30,
            text   = "error: \n" .. parameters.error,
            horizontallyCentered = true
        })
        properties.components["error"] = errorTextLine
    end

    local hint = TextField:new(_, {
        parent = properties,
        posY   = properties.contentY + 45,
        width  = 60,
        height = 1,
        text   = "Нажмите любую клавишу чтобы продолжить",
        centeredText = true,
        horizontallyCentered = true
    })
    properties.components["hint"] = hint

    local line = Line:new(_, {
        parent = properties,
        orientation = "horizontal",
        posY   = properties.contentY + 46,
        width  = 38,
        color  = properties.foregroundColor,
        horizontallyCentered = true
    })
    properties.components[#properties.components + 1] = line
end

function BSOD:processTouchEvent()
    if self.isUnrecoverable then
        computer.shutdown(true)
    end
    self:terminate()
end

function BSOD:processKeyDownEvent()
    if self.isUnrecoverable then
        computer.shutdown(true)
    end
    self:terminate()
end

function BSOD:processAddedFloppyEvent(address) end

return BSOD