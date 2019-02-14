-- InfOS
local Button       = require "system.components.common.button"
local PopUp        = require "system.popup"
local constants    = require "system.constants"
local icons        = require "system.icons"
-- Helpers
local StringHelper = require "system.helpers.stringHelper"
-- OpenOS
local component = require "component"
local gpu       = component.gpu

---@class Shortcut : Button
---@field parent Desktop
local Shortcut = Button:inherit({
    isSelected     = false,
    hasDefaultSize = true,

    doBottomFramePartRender = false,
})

---@param properties Shortcut
function Shortcut:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.height = constants.shortcutHeight
    properties.width  = constants.shortcutWidth

    parameters.text   = parameters.text or (parameters.app and parameters.app.windowName or "n/a")

    -- Call parent constructor
    Button:constructor(properties, parameters)

    properties.app        = parameters.app
    properties.executable = parameters.executable
    properties.parameters = parameters.parameters or {}

    properties.backgroundColor             = constants.shortcutBackgroundColor
    properties.selectedBackgroundColor     = constants.selectedShortcutBackgroundColor
    properties.textForegroundColor         = constants.shortcutTextForegroundColor
    properties.selectedTextForegroundColor = constants.selectedShortcutTextForegroundColor


    properties.iconDetailColor = constants.shortcutIconDetailColor
    properties.iconColor       = constants.shortcutIconColor
    properties.icon            = parameters.icon or (properties.app and (properties.app.icon or icons.unknown) or icons.unknown)
    properties.iconDetails     = properties.app and (properties.app.iconDetails or {}) or {}
end

function Shortcut:onTouch()
    if self.isSelected then
        if self.app then
            self.parent:callApp(self.app, self.parameters)
        elseif self.executable then
            self.parent:call(self.executable, self.parameters)
        else
            self.parent:call(PopUp, {
                windowName = "Уведомление",
                text = "Этот ярлык ещё не запрограммирован",
                centeredText          = true,
                doConfirmButtonRender = true,
                confirmButtonText     = "Ок",
                doCloseButtonRender   = false
            })
        end
        self.isSelected = false
    else
        self.isSelected = true
    end
    self:render()
end

function Shortcut:onFailedTouch()
    self.isSelected = false
    self:render()
end

function Shortcut:renderContent()
    -- label
    gpu.setForeground(self.isSelected and self.selectedTextForegroundColor or self.textForegroundColor)
    gpu.setBackground(self.isSelected and self.selectedBackgroundColor or self.backgroundColor)
    gpu.set(self.contentX + self.textIndent, self.contentY + self.contentHeight - 2, self.text)

    -- icon
    gpu.setForeground(self.iconColor)
    for posY, string in pairs(self.icon) do
        if posY > 10 then break end
        gpu.set(self.contentX + 4, self.contentY + 1 + posY, StringHelper:trim(string, 20, false))
    end

    -- icon details
    gpu.setForeground(self.isSelected and self.selectedBackgroundColor or self.backgroundColor)
    gpu.setBackground(self.iconColor)
    for _, detail in pairs(self.iconDetails) do
        if (detail.posY > 10) then goto continue end
        gpu.set(
            self.contentX + 4 + detail.posX,
            self.contentY + 1 + detail.posY,
            StringHelper:trim(detail.string, 20 - detail.posX, false)
        )
        ::continue::
    end

    return true
end

function Shortcut:renderBackground()
    gpu.setBackground(self.isSelected and self.selectedBackgroundColor or self.backgroundColor)
    gpu.fill(self.posX, self.posY, self.width, self.height, " ")
    return true
end

return Shortcut

