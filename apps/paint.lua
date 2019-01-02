--
-- Created by Ikamari, 02.01.2019 13:02
--

local Window        = require "window"
local ClickableZone = require "main.clickableZone"
local component     = require "component"
local gpu           = component.gpu

local Paint = Window:inherit({
    -- Properties
    windowName = "Рисовалка",
    renderSideBorders = false,

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

end

-- Also can be used to clean canvas
function Paint:renderCanvas()
    gpu.setBackground(0xFFFFFF)
    gpu.fill(self.canvasX, self.canvasY, self.canvasWidth, self.canvasHeight, " ")
    local canvasZone = ClickableZone:new(_, {
        x      = self.canvasX,
        y      = self.canvasY,
        width  = self.canvasWidth,
        height = self.canvasHeight,
        type   = "zone",
        parent = self,
        callback = function (properties, _, parameters)
            if properties.doDrawing then
                gpu.setBackground(0x000000)
                gpu.fill(parameters.x, parameters.y, 1, 1, " ")
            end
        end
    })
    self.clickableZones["canvas"] = canvasZone
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