-- InfOS
local UIComponent   = require "system.components.component"
local constants     = require "system.constants"
-- Helpers
local StringHelper  = require "system.helpers.stringHelper"
-- OpenOS
local unicode       = require "unicode"
local event         = require "event"
local component     = require "component"
local gpu           = component.gpu

---@class LinedInputField : UIComponent
local LinedInputField = UIComponent:inherit({
    canHandleKeyboardEvents = true,
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

function LinedInputField:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    UIComponent:constructor(properties, parameters)

    properties.maxLineLength = (parameters.maxLineLength and parameters.maxLineLength <= properties.contentWidth - 3) and parameters.maxLineLength or (properties.contentWidth - 3)
    properties.maxLines      = properties.contentHeight
    properties.lines         = {}
    -- Table with length of lines is used to optimize process of measuring length of strings with unicode symbols
    properties.linesLength   = {}

    properties:updateLines(parameters.initialLines or {}, properties, true)

    properties.placeholder      = parameters.placeholder and StringHelper:trim(parameters.placeholder, properties.contentWidth - 3) or ""
    properties.placeholderColor = parameters.placeholderColor or constants.componentPlaceholderColor
    properties.hiddenText       = parameters.hiddenText
    properties.filter           = parameters.filter

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
            elseif (properties.cursorY - 1 >= properties.contentY) then
                properties:updateCursor(true, properties.cursorX + properties.linesLength[currentLine - 1], properties.cursorY - 1)
            end
        end,

        -- right
        [205] = function(currentLine)
            if (properties.cursorX + 1 <= properties.contentX + properties.contentSideIndent + properties.linesLength[currentLine]) then
                properties:updateCursor(true, properties.cursorX + 1, properties.cursorY)
            elseif (properties.cursorY + 1 < properties.contentY + properties.maxLines) then
                properties:updateCursor(true, properties.contentX + properties.contentSideIndent, properties.cursorY + 1)
            end
        end,

        -- backspace
        [14] = function(currentLine)
            if (properties.cursorX > properties.contentX + properties.contentSideIndent) then
                local charsToRemoveFromEnd = (properties.linesLength[currentLine] + 1) - (properties.cursorX - (properties.contentX + properties.contentSideIndent))
                local charsToRemoveFromStart = properties.cursorX - (properties.contentX + properties.contentSideIndent)
                local firstPart  = StringHelper:removeFromEnd(properties.lines[currentLine], charsToRemoveFromEnd)
                local secondPart = StringHelper:removeFromStart(properties.lines[currentLine], charsToRemoveFromStart)
                properties.lines[currentLine] = firstPart .. secondPart
                properties.linesLength[currentLine] = properties.linesLength[currentLine] - 1
                properties:updateCursor(true, properties.cursorX - 1, properties.cursorY)
            elseif (properties.cursorY - 1 >= properties.contentY) then
                properties:updateCursor(true, properties.cursorX + properties.linesLength[currentLine - 1], properties.cursorY - 1)
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

    properties.blinkerId = nil
end

function LinedInputField:updateLines(lines, properties, skipRender)
    properties = properties or self

    local amountOfLines = 1
    for key, line in pairs(lines) do
        if (amountOfLines <= properties.maxLines) then
            line = StringHelper:trim(line, properties.maxLineLength)
            properties.lines[amountOfLines] = line
            properties.linesLength[amountOfLines] = StringHelper:getLength(line)
            amountOfLines = amountOfLines + 1
        end
    end

    for i = amountOfLines, properties.maxLines do
        properties.lines[i]       = ""
        properties.linesLength[i] = 0
    end

    if not skipRender then
        properties:render()
    end
end

-- -1 = no space for char
--  0 = character skipped
--  1 = char successfully added
function LinedInputField:addChar(char, skipRender)
    local currentLine = (self.cursorY - self.contentY) + 1

    if self.filter then
        if char:find(self.filter) == nil then
            return -1
        end
    end

    local isLineBreak = char:find("[\10]")

    if (isLineBreak) then
        if (currentLine < self.maxLineLength) then
            self:updateCursor(true, self.contentX + self.contentSideIndent, self.cursorY + 1)
            return 1
        else
            return 0
        end
    end

    if (self.linesLength[currentLine] < self.maxLineLength) then
        -- If there's enough of space for char in line, add it
        local charsToRemoveFromEnd    = self.linesLength[currentLine] - (self.cursorX - (self.contentX + self.contentSideIndent))
        local charsToRemoveFromStart  = self.cursorX - (self.contentX + self.contentSideIndent)
        local firstPart  = StringHelper:removeFromEnd(self.lines[currentLine], charsToRemoveFromEnd)
        local secondPart = StringHelper:removeFromStart(self.lines[currentLine], charsToRemoveFromStart)
        self.lines[currentLine]       = firstPart .. char .. secondPart
        self.linesLength[currentLine] = self.linesLength[currentLine] + 1
        self:updateCursor(true, self.cursorX + 1, self.cursorY, skipRender)
        return 1
    elseif (((self.cursorX - (self.contentX + self.contentSideIndent)) < self.maxLineLength) and (currentLine < self.maxLines)) then
        -- If cursor is not on end of line, then try to shift chars in front
        -- Check whether there's free space in lines below
        local hasNotFilledLine = false
        for line = currentLine + 1, self.maxLines do
            if (self.linesLength[line] < self.maxLineLength) then
                hasNotFilledLine = true
                break
            end
        end

        if (not hasNotFilledLine) then
            return 0
        end

        local currentCursorX = self.cursorX
        local currentCursorY = self.cursorY

        -- Subtract last symbol from current line and send it to next possible line
        local subtractedChar = unicode.sub(self.lines[currentLine], -1)
        local newCurrentLine = self.lines[currentLine]:gsub(".[\128-\191]*$", "")
        self.linesLength[currentLine] = self.linesLength[currentLine] - 1
        self.lines[currentLine]       = newCurrentLine

        self.cursorX = self.contentX  + self.contentSideIndent
        self.cursorY = currentCursorY + 1
        self:addChar(subtractedChar, true)

        -- Add new char to current line
        self.cursorX = currentCursorX
        self.cursorY = currentCursorY
        self:addChar(char, skipRender)

        return 1
    elseif (((self.cursorX - (self.contentX + self.contentSideIndent)) == self.maxLineLength) and (currentLine < self.maxLines)) then
        -- Skip whitespaces
        if char == " " then
            return 0
        end

        -- If cursor is on end of line, then try to send cursor to next line and continue adding char
        self:updateCursor(true, self.contentX + self.contentSideIndent, self.cursorY + 1)
        self:addChar(char, skipRender)

        return 1
    end

    return 0
end

function LinedInputField:renderContent()
    gpu.setBackground(self.textBackgroundColor)
    gpu.setForeground(self.textForegroundColor)
    local drawPlaceholder = true

    for key, line in pairs(self.lines) do
        if (line ~= "") then
            drawPlaceholder = false
            if (self.hiddenText) then
                line = line:gsub(".[\128-\191]*", "*")
            end
            gpu.set(self.contentX + self.contentSideIndent, (self.contentY + key) - 1, line)
        end
    end

    if (drawPlaceholder and self.focused ~= true) then
        gpu.setForeground(self.placeholderColor)
        gpu.set(self.contentX + self.contentSideIndent, self.contentY, self.placeholder)
    end

    return true
end

function LinedInputField:onTouch(parameters)
    self:updateCursor(true, parameters.x, parameters.y)
end

function LinedInputField:onFailedTouch()
    if (self.focused) then
        self:updateCursor(false)
    end
end

function LinedInputField:onClipboard(str)
    if (not self.focused) then
        return
    end

    for char in str:gmatch(".[\128-\191]*") do
        if self:addChar(char, true) == -1 then
            break
        end
    end

    self:render()
end

function LinedInputField:onKeyDown(charCode, code)
    if (not self.focused) then
        return
    end

    if (self.keyActions[code]) then
        local currentLine = (self.cursorY - self.contentY) + 1
        self.keyActions[code](currentLine)
        return
    end

    if (charCode ~= 0) then
        self:addChar(unicode.char(charCode))
    end
end

function LinedInputField:updateCursor(enable, x, y, skipRender)
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
        elseif (x > self.contentX + self.contentSideIndent + self.linesLength[(self.cursorY - self.contentY) + 1]) then
            self.cursorX = self.contentX + self.contentSideIndent + self.linesLength[(self.cursorY - self.contentY) + 1]
        else
            self.cursorX = x
        end
        
        if (self.focused == false and self.blinkerId == nil) then
            self.focused = true
            self.blinkerId = self.parent:addEvent(event.timer(0.5, self.blinkerCallback, math.huge))
        end
    else
        self.focused = false
        self.parent:cancelEvent(self.blinkerId)
        self.blinkerId = nil
    end
    if not skipRender then
        self:render()
    end
    if enable and not skipRender then
        self.blinkerCallback()
    end
    self.blinked = false
end

return LinedInputField