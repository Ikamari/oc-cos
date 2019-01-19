--
-- Created by Ikamari, 19.01.2019 0:45
--

-- COS
local Button        = require "system.ui.button"
local StringHelper  = require "system.helpers.stringHelper"
-- OOS
local component     = require "component"
local gpu           = component.gpu

local Switch = Button:inherit({})

function Switch:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    Button:constructor(properties, parameters)

    properties.activeLabelBackgroundColor   = parameters.activeLabelBackgroundColor   or 0x7e7e7e
    properties.unactiveLabelBackgroundColor = parameters.unactiveLabelBackgroundColor or 0x7e7e7e
    properties.activeLabelForegroundColor   = parameters.activeLabelForegroundColor   or 0x282828
    properties.unactiveLabelForegroundColor = parameters.unactiveLabelForegroundColor or 0x282828

    properties.activeLabel   = parameters.activeLabel   or "Вкл"
    properties.unactiveLabel = parameters.unactiveLabel or "Выкл"

    if parameters.doLabelRenderOnActive ~= nil then
        properties.doLabelRenderOnActive = parameters.doLabelRenderOnActive
    else
        properties.doLabelRenderOnActive = true
    end
    if parameters.doLabelRenderOnUnactive ~= nil then
        properties.doLabelRenderOnUnactive = parameters.doLabelRenderOnUnactive
    else
        properties.doLabelRenderOnUnactive = true
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

    local activeLabelLenght = StringHelper:getLength(properties.activeLabel)
    if activeLabelLenght + 2 < properties.width then
        properties.activeLabelIndent = math.floor((properties.width - activeLabelLenght) / 2)
    else
        properties.activeLabelIndent = 1
        properties.activeLabel = StringHelper:trim(properties.activeLabel, properties.width - 2)
    end

    local unactiveLabelLenght = StringHelper:getLength(properties.unactiveLabel)
    if unactiveLabelLenght + 2 < properties.width then
        properties.unactiveLabelIndent = math.floor((properties.width - unactiveLabelLenght) / 2)
    else
        properties.unactiveLabelIndent = 1
        properties.unactiveLabel = StringHelper:trim(properties.unactiveLabel, properties.width - 2)
    end
end

function Switch:renderLabel(state)
    if (state and not self.doLabelRenderOnActive)       then return false end
    if (not state and not self.doLabelRenderOnUnactive) then return false end

    gpu.setForeground(state and self.activeLabelForegroundColor or self.unactiveLabelForegroundColor)
    gpu.setBackground(state and self.activeLabelBackgroundColor or self.unactiveLabelBackgroundColor)
    gpu.set(self.posX + (state and self.activeLabelIndent or self.unactiveLabelIndent), self.posY, state and self.activeLabel or self.unactiveLabel)

    return true
end

function Switch:renderBackground(state)
    gpu.setBackground(state and self.activeLabelBackgroundColor or self.unactiveLabelBackgroundColor)
    gpu.fill(self.posX, self.posY, self.width, 1, " ")

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
    self:renderLabel(state)
end

return Switch