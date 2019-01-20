--
-- Created by Ikamari, 19.01.2019 12:57
--

local StringHelper = {}

function StringHelper:getLength(str)
    return select(2, string.gsub(str, "[^\128-\193]", ""))
end

function StringHelper:trim(str, maxLength)
    if self:getLength(str) > maxLength then
        local newStr = "";
        local i = 0
        for c in str:gmatch(".[\128-\191]*") do
            if i == maxLength - 1 then
                break
            else
                i = i + 1
                newStr = newStr .. c
            end
        end
        return newStr .. "…"

    else
        return str
    end
end

-- TODO: add newline support
function StringHelper:splitToLines(str, maxLineLength, maxLines)
    maxLines = maxLines or 1
    local words = require("text").tokenize(str)
    local lines = {}
    local currentLine = ""
    local currentLineLength = 0

    for _, word in pairs(words) do
        local wordLength       = self:getLength(word)
        ::again::
        local futureLineLength = wordLength + currentLineLength
        --print("Word:", word, "Word length:", wordLength, "Line num:", #lines, "Current text:", currentLine, "Current line length:", currentLineLength, "Future line length:", futureLineLength)

        if (futureLineLength <= maxLineLength) then
            -- Add word to line if it's not too long
            currentLineLength = currentLineLength + wordLength + (futureLineLength == maxLineLength and 0 or 1)
            currentLine = currentLine .. word .. (futureLineLength == maxLineLength and "" or " ")
        elseif (#lines + 1 == maxLines and currentLineLength <= maxLineLength) then
            -- If this is the last line, then insert trimmed word (if it's possible) and return lines
            if (currentLineLength ~= maxLineLength) then
                local maxWordLength = maxLineLength - currentLineLength
                currentLine = currentLine .. self:trim(word, maxWordLength)
            end
            lines[#lines + 1] = currentLine
            return lines
        elseif (currentLineLength == 0) then
            -- If current line is empty, but word is too long, then add it to current line
            lines[#lines + 1] = word
        else
            -- Go to next line and repeat this iteration
            lines[#lines + 1] = currentLine
            currentLine = ""
            currentLineLength = 0
            goto again
        end
    end

    lines[#lines + 1] = currentLine
    return lines
end

return StringHelper