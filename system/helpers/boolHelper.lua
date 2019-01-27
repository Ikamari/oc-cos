---
--- Created by Ikamari.
--- DateTime: 27.01.2019 18:34
---

local BoolHelper = {}

function BoolHelper:toInt(bool)
    return bool and 1 or 2
end

return BoolHelper
