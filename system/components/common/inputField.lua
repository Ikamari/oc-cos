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
    text = "",
    textLength = 0,
    textIndent = 2,
    focused    = false,
    cursorX    = nil,
    cursorY    = nil
})

function InputField:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    UIComponent:constructor(properties, parameters)

    properties.frameColor           = parameters.frameColor or 0x555547
    properties.backgroundColor      = parameters.backgroundColor  or 0x282828
    properties.textBackgroundColor  = parameters.backgroundColor  or 0x7e7e7e
    properties.textForegroundColor  = parameters.foregroundColor  or 0x282828

    properties.maxLineLength = properties.width - properties.textIndent * 2
    properties.maxLines      = properties.height
    properties.lines         = {}
    properties.linesLength   = {}

    for i = 0, properties.maxLines - 1 do
        properties.lines[i]       = ""
        properties.linesLength[i] = 0
    end

    properties.placeholder      = parameters.placeholder ~= "" and StringHelper:trim(parameters.placeholder, properties.maxLineLength) or ""
    properties.placeholderColor = parameters.placeholderColor or 0xa59c83
end

function InputField:renderLines()
    gpu.setBackground(self.textBackgroundColor)
    gpu.setForeground(self.textForegroundColor)
    local drawPlaceholder = true

    for key, line in pairs(self.lines) do
        if (line ~= "") then
            drawPlaceholder = false
            gpu.set(self.posX + self.textIndent, self.posY + key, line)
        end
    end

    if (drawPlaceholder and self.focused ~= true) then
        gpu.setForeground(self.placeholderColor)
        gpu.set(self.posX + self.textIndent, self.posY, self.placeholder)
    end

    return true
end

function InputField:renderFrame()
    gpu.setForeground(self.parent.backgroundColor)
    gpu.setBackground(self.frameColor)

    -- bottom
    gpu.fill(self.posX, self.posY + self.height, self.width, 1, "▆")
    -- right
    gpu.fill(self.posX + self.width - 1, self.posY, 1, self.height, " ")
    -- left
    gpu.fill(self.posX, self.posY, 1, self.height, " ")

    gpu.setForeground(self.frameColor)
    gpu.setBackground(self.parent.backgroundColor)

    -- top
    gpu.fill(self.posX, self.posY - 1, self.width, 1, "▂")

    return true
end

function InputField:renderBackground()
    gpu.setBackground(self.textBackgroundColor)
    gpu.fill(self.posX + 1, self.posY, self.width - 2, self.height, " ")

    return true
end

function InputField:render()
    self:renderBackground()
    self:renderFrame()
    self:renderLines()
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
        --print(char, code)
        local currentLine = self.cursorY - self.posY

        -- up
        if (code == 200) then
            if (self.cursorY - 1 >= self.posY) then self:updateCursor(true, self.cursorX, self.cursorY - 1) end
            return
        end

        -- down or enter
        if (code == 208 or code == 28) then
            if (self.cursorY + 1 < self.posY + self.maxLines) then self:updateCursor(true, self.cursorX, self.cursorY + 1) end
            return
        end

        -- left
        if (code == 203) then
            if (self.cursorX - 1 >= self.posX + self.textIndent) then self:updateCursor(true, self.cursorX - 1, self.cursorY) end
            return
        end

        -- right
        if (code == 205) then
            if (self.cursorX + 1 <= self.posX + self.textIndent + self.linesLength[currentLine]) then self:updateCursor(true, self.cursorX + 1, self.cursorY) end
            return
        end

        -- backspace
        if (code == 14) then
            if (self.cursorX ~= self.posX + self.textIndent) then
                local charsToRemoveFromEnd    = (self.linesLength[currentLine] + 1) - (self.cursorX - (self.posX + self.textIndent))
                local charsToRemoveFromStart  = self.cursorX - (self.posX + self.textIndent)
                local firstPart  = StringHelper:removeFromEnd(self.lines[currentLine], charsToRemoveFromEnd)
                local secondPart = StringHelper:removeFromStart(self.lines[currentLine], charsToRemoveFromStart)
                self.lines[currentLine] = firstPart .. secondPart
                self.linesLength[currentLine] = self.linesLength[currentLine] - 1
                self:updateCursor(true, self.cursorX - 1, self.cursorY)
            end
            return
        end

        if (char ~= 0) then
            if (self.linesLength[currentLine] < self.maxLineLength) then
                local charsToRemoveFromEnd    = self.linesLength[currentLine] - (self.cursorX - (self.posX + self.textIndent))
                local charsToRemoveFromStart  = self.cursorX - (self.posX + self.textIndent)
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
        gpu.setBackground(self.textBackgroundColor)
        gpu.setForeground(self.placeholderColor)

        -- Define cursor's y
        if (y < self.posY) then
            self.cursorY = self.posY
        elseif (y > self.posY + self.maxLines) then
            self.cursorY = self.posY + self.maxLines
        else
            self.cursorY = y
        end
        -- Define cursor's x
        if (x < self.posX + self.textIndent) then
            self.cursorX = self.posX + self.textIndent
        elseif (x > self.posX + self.textIndent + self.linesLength[self.cursorY - self.posY]) then
            self.cursorX = self.posX + self.textIndent + self.linesLength[self.cursorY - self.posY]
        else
            self.cursorX = x
        end
        
        if (self.focused == false) then
            self.focused = true
            local callback = function ()
                local character, color1, color2 = gpu.get(self.cursorX, self.cursorY)
                gpu.setForeground(color2)
                gpu.setBackground(color1)
                gpu.set(self.cursorX, self.cursorY, character)
            end
            self.parent:addEvent(event.timer(0.5, callback, math.huge), "blinker")
        end
    else
        self.focused = false
        self.parent:cancelEvent("blinker")
    end
    self:renderBackground()
    self:renderLines()
end

return InputField