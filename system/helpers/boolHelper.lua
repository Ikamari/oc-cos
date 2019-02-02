local BoolHelper = {}

function BoolHelper:toInt(bool)
    return bool and 1 or 0
end

return BoolHelper
