-- InfOS
local BasicApp   = require "system.app"
-- OpenOS
local computer = require "computer"

---@class AuthForm : BasicApp
local AuthForm = BasicApp:inherit({
    -- Properties
    doFrameRender       = false,
    doBackgroundRender  = true,
    doWindowNameRender  = false,
    doCloseButtonRender = false,
    autoSize = false,
    contentIndent = 0
    --
})

---@param properties BasicApp
function AuthForm:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)

    properties.keyDownHandlers[#properties.keyDownHandlers + 1] = function(_, code)
        if (code == 28) then
            properties:submit()
        end
    end
end

function AuthForm:submit() end

function AuthForm:processInterruptEvent()
    computer.beep(750, 0.02)
    computer.beep(750, 0.02)
    computer.beep(750, 0.02)
end

return AuthForm