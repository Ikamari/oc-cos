--
-- Created by Ikamari, 19.01.2019 12:57
--

local StringHelper = {}

function StringHelper:getLength(str)
    return select(2, string.gsub(str, "[^\128-\193]", ""))
end

function StringHelper:trim(str, maxLenght)
    if self:getLength(str) > maxLenght then
        local newStr = "";
        local i = 0
        for c in str:gmatch(".[\128-\191]*") do
            i = i + 1
            newStr = newStr .. c
            if i == maxLenght - 1 then
                break
            end
        end
        return newStr .. "…"

    else
        return str
    end
end

return StringHelper