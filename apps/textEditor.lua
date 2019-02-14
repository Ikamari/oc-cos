-- InfOS
local BasicApp  = require "system.app"
local PopUp     = require "system.popup"
local constants = require "system.constants"
local icons     = require "system.icons"
-- Components
local Button          = require "system.components.common.button"
local Switch          = require "system.components.common.switch"
local TextField       = require "system.components.common.textField"
local LinedInputField = require "system.components.common.linedInputField"
-- OpenOS
local component = require "component"
local gpu       = component.gpu

---@class TextEditor : BasicApp
local TextEditor = BasicApp:inherit({
    windowName = "Текстовый редактор",
    icon       = icons.document,
    MAX_PAGES  = 9
})

---@param properties TextEditor
function TextEditor:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)

    properties.currentPage = 1
    properties.pages       = {}
    table.insert(properties.pages, properties:createBlankPage())

    -- Main input field
    properties:addComponent(LinedInputField, {
        posX   = -1,
        posY   = properties.contentY + 1,
        width  = 30,
        height = 20,
        horizontallyCentered = true
    }, properties, "text_field")

    -- Page select
    properties:addComponent(Button, {
        posX   = -9,
        posY   = properties.contentY + 23,
        width  = 9,
        height = 1,
        text   = "Пред.",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:selectPreviousPage()
        end
    }, properties, "select_previous_page_button")

    properties:addComponent(TextField, {
        posY   = properties.contentY + 23,
        width  = 6,
        height = 1,
        text   = "1 из 1",
        centeredText = true,
        horizontallyCentered = true,
    }, properties, "page_info")

    properties:addComponent(Button, {
        posX   = 10,
        posY   = properties.contentY + 23,
        width  = 9,
        height = 1,
        text   = "След.",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:selectNextPage()
        end
    }, properties, "select_next_page_button")
    --

    -- Page controls
    properties:addComponent(Button, {
        posY   = properties.contentY + 26,
        width  = 32,
        height = 1,
        text   = "Создать новую страницу",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:createPage()
        end
    }, properties, "create_page_button")

    properties:addComponent(Button, {
        posY   = properties.contentY + 28,
        width  = 32,
        height = 1,
        text   = "Очистить страницу",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:clearPage()
        end
    }, properties, "clear_page_button")

    properties:addComponent(Button, {
        posY   = properties.contentY + 30,
        width  = 32,
        height = 1,
        text   = "Удалить  страницу",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:deletePage()
        end
    }, properties, "delete_page_button")
    --
end

function TextEditor:createBlankPage()
    return { "", "", "", "", "", "", "", "", "", "", "" , "", "", "", "", "", "", "", "", "" }
end

function TextEditor:showConfirmation(text)
    return self:call(PopUp, {
        windowName = "Подтверждение",
        text = "Вы уверены, что хотите " .. text .. "?",
        centeredText = true,
        type = "warning",
        doConfirmButtonRender = true,
        doDenyButtonRender    = true,
        doCloseButtonRender   = false
    })
end

function TextEditor:showWarning(text)
    return self:call(PopUp, {
        windowName = "Уведомление",
        text       = text,
        centeredText          = true,
        doConfirmButtonRender = true,
        confirmButtonText     = "Ок",
        doCloseButtonRender   = false
    })
end

function TextEditor:debug()
    for key, value in pairs(self.pages[self.currentPage]) do
        gpu.setForeground(0xFFFFFF)
        gpu.set(1, key, "                                             ")
        gpu.set(1, key, key .. ": " .. value)
    end
    os.sleep(1)
end

function TextEditor:selectPage(futurePage)
    -- Check whether it's possible to change page
    if (futurePage < 1 or futurePage > #self.pages) then
        return false
    end

    -- Save current page in text editor
    self:savePage()

    -- Update text editor properties
    self.currentPage = futurePage

    -- Re-render component that tells current page
    self:getComponent("page_info"):updateText(self.currentPage .. " из " .. #self.pages)

    -- Update text in input field
    self:getComponent("text_field"):updateLines(self.pages[self.currentPage])

    return true
end

function TextEditor:savePage()
    -- Save current page in text editor
    --self:debug()
    if self.pages[self.currentPage] then
        for key, string in pairs (self:getComponent("text_field").lines) do
            self.pages[self.currentPage][key] = string
        end
    end
    --self:debug()
end

function TextEditor:selectNextPage()
    return self:selectPage(self.currentPage + 1)
end

function TextEditor:selectPreviousPage()
    return self:selectPage(self.currentPage -1)
end

function TextEditor:createPage()
    -- Check whether the document has reached maximum amount of pages
    local futurePage = #self.pages + 1
    if futurePage > self.MAX_PAGES then
        self:showWarning("Достигнуто максимальное количество страниц")
        return false
    end

    -- Create new blank page
    table.insert(self.pages, self:createBlankPage())

    -- Open new page
    self:selectPage(futurePage)

    return true
end

function TextEditor:clearPage()
    -- Ask user to confirm his action
    if not self:showConfirmation("очистить текущую страницу") then
        return false
    end

    -- Clear current page
    self.pages[self.currentPage] = self:createBlankPage()
    self:getComponent("text_field"):updateLines(self.pages[self.currentPage])

    return true
end

function TextEditor:deletePage()
    -- Check how many pages left and don't let do delete the last one
    if #self.pages <= 1 then
        self:showWarning("Вы не можете удалить единственную страницу")
        return false
    end

    -- Ask user to confirm his action
    if not self:showConfirmation("удалить текущую страницу") then
        return false
    end

    -- Delete current page
    table.remove(self.pages, self.currentPage)

    -- Open existing page (previous page is in priority)
    if not self:selectPage(self.currentPage) then
        if not self:selectPreviousPage() then
            -- Return critical error if text editor will fall into a stalemate
            error("Текстовый редактор зашёл в тупик с выбором страницы")
        end
    end

    return true
end

return TextEditor