--
-- Created by Ikamari, 19.01.2019 0:43
--

-- COS
local UIComponent   = require "system.components.component"
local StringHelper  = require "system.helpers.stringHelper"
-- OOS
local unicode       = require "unicode"
local event         = require "event"
local component     = require "component"
local gpu           = component.gpu

local InputField = UIComponent:inherit({
    contentSideIndent       = 1, -- left and right margin for content

    doTopFramePartRender    = true,
    doBottomFramePartRender = true,
    doLeftFramePartRender   = true,
    doRightFramePartRender  = true,

    focused   = false,
    blinked   = false,
    cursorX   = nil,
    cursorY   = nil
})

function InputField:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    UIComponent:constructor(properties, parameters)

    properties.maxLineLength = properties.contentWidth - 3
    properties.maxLines      = properties.contentHeight
    properties.lines         = {}
    properties.linesLength   = {}

    for i = 0, properties.maxLines - 1 do
        properties.lines[i]       = ""
        properties.linesLength[i] = 0
    end

    properties.placeholder      = parameters.placeholder ~= "" and StringHelper:trim(parameters.placeholder, properties.maxLineLength) or ""
    properties.placeholderColor = parameters.placeholderColor or 0xa59c83

    properties.keyActions = {
        -- Up
        [200] = function(currentLine)
            if (properties.cursorY - 1 >= properties.contentY) then
                properties:updateCursor(true, properties.cursorX, properties.cursorY - 1)
            end
        end,

        -- down or enter
        [208] = function(currentLine)
            if (properties.cursorY + 1 < properties.contentY + properties.maxLines) then
                properties:updateCursor(true, properties.cursorX, properties.cursorY + 1)
            end
        end,

        -- left
        [203] = function(currentLine)
            if (properties.cursorX - 1 >= properties.contentX + properties.contentSideIndent) then
                properties:updateCursor(true, properties.cursorX - 1, properties.cursorY)
            end
        end,

        -- right
        [205] = function(currentLine)
            if (properties.cursorX + 1 <= properties.contentX + properties.contentSideIndent + properties.linesLength[currentLine]) then
                properties:updateCursor(true, properties.cursorX + 1, properties.cursorY)
            end
        end,

        -- backspace
        [14] = function(currentLine)
            if (properties.cursorX ~= properties.contentX + properties.contentSideIndent) then
                local charsToRemoveFromEnd = (properties.linesLength[currentLine] + 1) - (properties.cursorX - (properties.contentX + properties.contentSideIndent))
                local charsToRemoveFromStart = properties.cursorX - (properties.contentX + properties.contentSideIndent)
                local firstPart  = StringHelper:removeFromEnd(properties.lines[currentLine], charsToRemoveFromEnd)
                local secondPart = StringHelper:removeFromStart(properties.lines[currentLine], charsToRemoveFromStart)
                properties.lines[currentLine] = firstPart .. secondPart
                properties.linesLength[currentLine] = properties.linesLength[currentLine] - 1
                properties:updateCursor(true, properties.cursorX - 1, properties.cursorY)
            end
        end
    }
    properties.keyActions[28] = properties.keyActions[208]

    properties.blinkerCallback = function ()
        properties.blinked = not properties.blinked
        local character = gpu.get(properties.cursorX, properties.cursorY)
        gpu.setForeground(properties.textForegroundColor)
        gpu.setBackground(properties.blinked and properties.placeholderColor or properties.textBackgroundColor)
        gpu.set(properties.cursorX, properties.cursorY, character)
    end
end

function InputField:renderContent()
    gpu.setBackground(self.textBackgroundColor)
    gpu.setForeground(self.textForegroundColor)
    local drawPlaceholder = true

    for key, line in pairs(self.lines) do
        if (line ~= "") then
            drawPlaceholder = false
            gpu.set(self.contentX + self.contentSideIndent, self.contentY + key, line)
        end
    end

    if (drawPlaceholder and self.focused ~= true) then
        gpu.setForeground(self.placeholderColor)
        gpu.set(self.contentX + self.contentSideIndent, self.contentY, self.placeholder)
    end

    return true
end

function InputField:onTouch(parameters)
    self:updateCursor(true, parameters.x, parameters.y)
end

function InputField:onFailedTouch()
    if (self.focused) then
        self:updateCursor(false)
    end
end

function InputField:onKeyDown(char, code)
    if (self.focused) then
        local currentLine = self.cursorY - self.contentY

        if (self.keyActions[code]) then
            self.keyActions[code](currentLine)
            return
        end

        if (char ~= 0) then
            if (self.linesLength[currentLine] < self.maxLineLength) then
                local charsToRemoveFromEnd    = self.linesLength[currentLine] - (self.cursorX - (self.contentX + self.contentSideIndent))
                local charsToRemoveFromStart  = self.cursorX - (self.contentX + self.contentSideIndent)
                local firstPart  = StringHelper:removeFromEnd(self.lines[currentLine], charsToRemoveFromEnd)
                local secondPart = StringHelper:removeFromStart(self.lines[currentLine], charsToRemoveFromStart)
                self.lines[currentLine]       = firstPart .. unicode.char(char) .. secondPart
                self.linesLength[currentLine] = self.linesLength[currentLine] + 1
                self:updateCursor(true, self.cursorX + 1, self.cursorY)
            end
        end
    end
end

function InputField:updateCursor(enable, x, y)
    if (enable) then
        self.blinked = false

        -- Define cursor's y
        if (y < self.contentY) then
            self.cursorY = self.contentY
        elseif (y > self.contentY + self.maxLines) then
            self.cursorY = self.contentY + self.maxLines
        else
            self.cursorY = y
        end
        -- Define cursor's x
        if (x < self.contentX + self.contentSideIndent) then
            self.cursorX = self.contentX + self.contentSideIndent
        elseif (x > self.contentX + self.contentSideIndent + self.linesLength[self.cursorY - self.contentY]) then
            self.cursorX = self.contentX + self.contentSideIndent + self.linesLength[self.cursorY - self.contentY]
        else
            self.cursorX = x
        end
        
        if (self.focused == false) then
            self.focused = true
            self.parent:addEvent(event.timer(0.5, self.blinkerCallback, math.huge), "blinker")
        end
    else
        self.focused = false
        self.parent:cancelEvent("blinker")
    end
    self:render()
    self.blinkerCallback()
    self.blinked = false
end

return InputField