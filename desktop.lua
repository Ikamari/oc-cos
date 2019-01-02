--
-- Created by Ikamari, 14.12.2018 23:35
--

local Window   = require "window"
local PopUp    = require "popup"
--local Paint    = require "apps.paint"
local computer = require("component").computer

local Desktop = Window:inherit({
    -- Properties
    doWindowFrameRender = false,
    doBackgroundRender  = true,
    doWindowNameRender  = false,
    doCloseButtonRender = false,

    autoSize          = false
    --
})

function Desktop:processKeyDownEvent(a, b, c, d)
--    print (c)
    if c == 2 then
        local popUp = PopUp:new(_, {
            windowName = "Уведомление",
            text       = "-",
            type       = "default"
        })
        popUp:init()

        self:renderWindowBackground()
        self:renderContent()
    elseif c == 3 then
        local popUp = PopUp:new(_, {
            windowName = "Предупреждение",
            text       = "?!",
            type       = "warning"
        })
        popUp:init()

        self:renderWindowBackground()
        self:renderContent()
    elseif c == 4 then
        local popUp = PopUp:new(_, {
            windowName = "Ошибка",
            text       = "All your base are belong to us",
            type       = "error"
        })
        popUp:init()

        self:renderWindowBackground()
        self:renderContent()
--    elseif c == 5 then
--        local popUp = Paint:new(_, {
--            windowX = self.contentX,
--            windowY = self.contentY
--        })
--        popUp:init()
--
--        self:renderWindowBackground()
--        self:renderContent()
    end
end

function Desktop:processInterruptEvent()
    computer.beep(750, 0.02)
    computer.beep(750, 0.02)
    computer.beep(750, 0.02)
end

return Desktop