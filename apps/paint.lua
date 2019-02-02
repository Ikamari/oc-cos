-- COS
local Window        = require "system.window"
local ClickableZone = require "system.components.clickableZone"
-- OOS
local component     = require "component"
local gpu           = component.gpu

---@class Paint : Window
local Paint = Window:inherit({
    -- Properties
    windowName = "Рисовалка",

    doDrawing = true
    --
})

function Paint:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    Window:constructor(properties, parameters)

    properties.canvasX      = properties.contentX
    properties.canvasY      = properties.contentY
    properties.canvasWidth  = properties.contentWidth
    properties.canvasHeight = properties.contentHeight

    local canvasZone = ClickableZone:new(_, {
        x      = properties.canvasX,
        y      = properties.canvasY,
        width  = properties.canvasWidth,
        height = properties.canvasHeight,
        type   = "zone",
        parent = properties,
        callback = function (properties, _, parameters)
            if properties.doDrawing then
                gpu.setBackground(0x000000)
                gpu.fill(parameters.x, parameters.y, 1, 1, " ")
            end
        end
    })
    properties.clickableZones["canvas"] = canvasZone
end

-- Also can be used to clean canvas
function Paint:renderCanvas()
    gpu.setBackground(0xFFFFFF)
    gpu.fill(self.canvasX, self.canvasY, self.canvasWidth, self.canvasHeight, " ")
end

function Paint:renderContent()
    self:renderCanvas()
end

function Paint:processTouchEvent(a, b, c, d)
    for key, zone in pairs(self.clickableZones) do
        if type(key) == "number" then
            zone:check(b, c)
        end
    end
    self.clickableZones["canvas"]:check(b, c, { x = b, y = c })
end

function Paint:processDragEvent(a, b, c, d)
    self.clickableZones["canvas"]:check(b, c, { x = b, y = c })
end

return Paint