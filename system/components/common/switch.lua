-- COS
local Button        = require "system.components.common.button"
local StringHelper  = require "system.helpers.stringHelper"
-- OOS
local component     = require "component"
local gpu           = component.gpu

---@class Switch : Button
local Switch = Button:inherit({})

function Switch:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    Button:constructor(properties, parameters)

    properties.activeTextBackgroundColor   = parameters.activeTextBackgroundColor   or 0x7e7e7e
    properties.unactiveTextBackgroundColor = parameters.unactiveTextBackgroundColor or 0x7e7e7e
    properties.activeTextForegroundColor   = parameters.activeTextForegroundColor   or 0x282828
    properties.unactiveTextForegroundColor = parameters.unactiveTextForegroundColor or 0x282828

    properties.activeText   = parameters.activeText   or "Вкл"
    properties.unactiveText = parameters.unactiveText or "Выкл"

    if parameters.doTextRenderOnActive ~= nil then
        properties.doTextRenderOnActive = parameters.doTextRenderOnActive
    else
        properties.doTextRenderOnActive = true
    end
    if parameters.doTextRenderOnUnactive ~= nil then
        properties.doTextRenderOnUnactive = parameters.doTextRenderOnUnactive
    else
        properties.doTextRenderOnUnactive = true
    end

    properties.standalone = parameters.standalone or true
    if (properties.standalone) then
        properties.state = parameters.defaultState or false
    else
        properties.tableReference = parameters.tableReference or properties.parent

        if (not parameters.tableKey) then
            error("Switch must receive \"tableKey\" string/number parameter that refers to table property")
        end
        if (properties.tableReference[parameters.tableKey] == nil) then
            error("Switch \"tableKey\" parameter refers to not existing table property")
        end

        properties.tableKey = parameters.tableKey
    end

    local activeLabelLength = StringHelper:getLength(properties.activeText)
    if activeLabelLength + 2 < properties.contentWidth then
        properties.activeTextIndent = math.floor((properties.contentWidth - activeLabelLength) / 2)
    else
        properties.activeTextIndent = 0
        properties.activeText = StringHelper:trim(properties.activeText, properties.contentWidth - 2)
    end

    local unactiveLabelLength = StringHelper:getLength(properties.unactiveText)
    if unactiveLabelLength + 2 < properties.contentWidth then
        properties.unactiveTextIndent = math.floor((properties.contentWidth - unactiveLabelLength) / 2)
    else
        properties.unactiveTextIndent = 0
        properties.unactiveText = StringHelper:trim(properties.unactiveText, properties.contentWidth - 2)
    end
end

function Switch:renderContent(state)
    if (state and not self.doTextRenderOnActive)       then return false end
    if (not state and not self.doTextRenderOnUnactive) then return false end

    gpu.setForeground(state and self.activeTextForegroundColor or self.unactiveTextForegroundColor)
    gpu.setBackground(state and self.activeTextBackgroundColor or self.unactiveTextBackgroundColor)
    gpu.set(self.contentX + (state and self.activeTextIndent or self.unactiveTextIndent), self.contentY, state and self.activeText or self.unactiveText)

    return true
end

function Switch:renderBackground(state)
    gpu.setBackground(state and self.activeTextBackgroundColor or self.unactiveTextBackgroundColor)
    gpu.fill(self.posX, self.posY, self.width, self.height, " ")

    return true
end

function Switch:onTouch()
    if (self.standalone) then
        self.state = not self.state
        self.onTouchCallback(self.state)
    else
        self.tableReference[self.tableKey] = not self.tableReference[self.tableKey]
        self.onTouchCallback(self.tableReference[self.tableKey])
    end
    self:render()
end

function Switch:render()
    local state
    if (self.standalone) then
        state = self.state
    else
        state = self.tableReference[self.tableKey]
    end

    self:renderBackground(state)
    self:renderFrame(state)
    self:renderContent(state)
end

return Switch