-- COS
local Object        = require "system.main.object"
local ClickableZone = require "system.components.clickableZone"
local BoolHelper    = require "system.helpers.boolHelper"
-- OOS
local component     = require "component"
local gpu           = component.gpu

---@class UIComponent
local UIComponent = Object:inherit({
    mustHaveParentReference = true,
    hasDefaultSize          = false,

    doFrameRender           = true,
    doTopFramePartRender    = false,
    doBottomFramePartRender = true,
    doLeftFramePartRender   = false,
    doRightFramePartRender  = false,

    doBackgroundRender      = true,
    contentSideIndent       = 1, -- left and right margin for content

    isVisible = true
})

function UIComponent:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    if (not parameters.parent and properties.mustHaveParentReference) then
        error("Component must receive reference to it's parent as parameter")
    end
    properties.parent = parameters.parent

    if (not properties.hasDefaultSize) then
        if type(parameters.width) ~= "number" or type(parameters.height) ~= "number" then
            error("Component must receive \"width\" and height\" number parameters")
        end

        properties.width  = parameters.width
        properties.height = parameters.height
    end

    if (type(parameters.posX) ~= "number" and parameters.horizontallyCentered ~= true) or type(parameters.posY) ~= "number" then
        error("Component must receive \"posX\" and \"posY\" number parameters")
    end

    properties.frameColor          = parameters.frameColor      or 0x555547
    properties.backgroundColor     = parameters.backgroundColor or 0x7e7e7e
    properties.textBackgroundColor = parameters.backgroundColor or 0x7e7e7e
    properties.textForegroundColor = parameters.foregroundColor or 0x282828

    if parameters.horizontallyCentered then
        local componentWidth = properties.width + BoolHelper:toInt(parameters.doLeftFramePartRender) + BoolHelper:toInt(parameters.doRightFramePartRender)
        properties.posX = properties.parent.contentX + math.ceil((properties.parent.contentWidth - componentWidth) / 2)
        if (parameters.posX) then
            properties.posX = properties.posX + parameters.posX
        end
    else
        properties.posX = parameters.posX
    end
    properties.posY = parameters.posY

    properties.contentY      = properties.posY
    properties.contentHeight = properties.height

    local clickableZone = ClickableZone:new(_, {
        x      = properties.posX,
        y      = properties.posY,
        width  = properties.width,
        height = properties.height,
        type   = "zone",
        parent = properties,
        callback = function (properties, _, parameters)
            properties:onTouch(parameters)
        end,
        onFailCallback = function (properties, _, parameters)
            properties:onFailedTouch(parameters)
        end
    })

    if properties.doFrameRender then
        if properties.doTopFramePartRender then
            properties.height   = properties.height + 1
            properties.contentY = properties.contentY + 1

            clickableZone.minY = clickableZone.minY + 1
            clickableZone.maxY = clickableZone.maxY + 1
        end

        if properties.doBottomFramePartRender then
            properties.height = properties.height + 1
        end

        if properties.doLeftFramePartRender then
            properties.width = properties.width + 1

            clickableZone.minX = clickableZone.minX + 1
            clickableZone.maxX = clickableZone.maxX + 1
        end

        if properties.doRightFramePartRender then
            properties.width = properties.width + 1
        end
    end

    properties.contentX      = properties.posX + properties.contentSideIndent
    properties.contentWidth  = properties.width - properties.contentSideIndent


    if parameters.onTouchCallback and type(parameters.onTouchCallback) ~= "function" then
        error("Component must receive \"onTouchCallback\" parameter of \"function\" type")
    end
    if parameters.onFailedTouchCallbac and type(parameters.onFailedTouchCallback) ~= "function" then
        error("Component must receive \"onFailedTouchCallback\" parameter of \"function\" type")
    end

    properties.onTouchCallback       = parameters.onTouchCallback or function() end
    properties.onFailedTouchCallback = parameters.onFailedTouchCallback or function() end

    properties.clickableZone = clickableZone
end

function UIComponent:onTouch()
    self.onTouchCallback()
end

function UIComponent:onFailedTouch()
    self.onFailedTouchCallback()
end

function UIComponent:renderContent()
    return true
end

function UIComponent:renderFrame()
    if self.doFrameRender == false then
        return false
    end

    gpu.setForeground(self.parent.backgroundColor)
    gpu.setBackground(self.frameColor)

    -- right
    if self.doRightFramePartRender then
        gpu.fill(self.posX + self.width - 1, self.posY, 1, self.height, " ")
    end
    -- left
    if self.doLeftFramePartRender then
        gpu.fill(self.posX, self.posY, 1, self.height, " ")
    end
    -- bottom
    if self.doBottomFramePartRender then
        gpu.fill(self.posX, self.posY + self.height - 1, self.width, 1, "▆")
    end

    -- top
    if self.doTopFramePartRender then
        gpu.setForeground(self.frameColor)
        gpu.setBackground(self.parent.backgroundColor)

        -- top
        gpu.fill(self.posX, self.posY, self.width, 1, "▂")
    end

    return true
end

function UIComponent:renderBackground()
    if self.doBackgroundRender == false then
        return false
    end

    gpu.setBackground(self.backgroundColor)
    gpu.fill(self.posX, self.posY, self.width, self.height, " ")

    return true
end

function UIComponent:render()
    if self.isVisible then
        self:renderBackground()
        self:renderFrame()
        self:renderContent()
    end
end

return UIComponent
