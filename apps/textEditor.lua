-- InfOS
local BasicApp  = require "system.app"
local Explorer  = require "system.explorer"
local PopUp     = require "system.popup"
local constants = require "system.constants"
local icons     = require "system.icons"
-- Components
local Button          = require "system.components.common.button"
local Switch          = require "system.components.common.switch"
local TextField       = require "system.components.common.textField"
local LinedInputField = require "system.components.common.linedInputField"
-- OpenOS
local event     = require "event"
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

    -- Document name
    properties:addComponent(TextField, {
        posX   = properties.contentX,
        posY   = properties.contentY,
        width  = 15,
        height = 1,
        text   = "Название файла:",
        centeredText = true,
    }, properties, "document_name_label")

    properties:addComponent(LinedInputField, {
        posX   = properties.contentX + 16,
        posY   = properties.contentY - 1,
        width  = 33,
        height = 1,
        filter = "[%w%._%-]"
    }, properties, "document_name_field")

    properties:addComponent(TextField, {
        posX   = properties.contentX + 53,
        posY   = properties.contentY,
        width  = 98,
        height = 1,
        text   = "Заметка: в названии могут быть только буквы латинского алфавита, цифры и символы: \"-\", \"_\" и \".\"",
    }, properties, "document_name_note")

    -- Document controls
    properties:addComponent(Button, {
        posX   = properties.contentX,
        posY   = properties.contentY + 2,
        width  = 12,
        height = 1,
        text   = "Создать",
        onTouchCallback = function()
            properties:createDocument()
        end
    }, properties, "new_document_button")

    properties:addComponent(Button, {
        posX   = properties.contentX + 13,
        posY   = properties.contentY + 2,
        width  = 12,
        height = 1,
        text   = "Открыть…",
        onTouchCallback = function()
            properties:openDocument()
        end
    }, properties, "save_document_button")

    properties:addComponent(Button, {
        posX   = properties.contentX + 26,
        posY   = properties.contentY + 2,
        width  = 12,
        height = 1,
        text   = "Сохранить",
        onTouchCallback = function()
            properties:saveDocument()
        end
    }, properties, "open_document_button")

    properties:addComponent(Button, {
        posX   = properties.contentX + 39,
        posY   = properties.contentY + 2,
        width  = 12,
        height = 1,
        text   = "Печать…",
        onTouchCallback = function()
            properties:printDocument()
        end
    }, properties, "print_document_button")

    properties:addComponent(TextField, {
        posX   = properties.contentX + 53,
        posY   = properties.contentY + 2,
        width  = 98,
        height = 1,
        text   = "",
    }, properties, "document_action_result")

    -- Main input field
    properties:addComponent(LinedInputField, {
        posX   = -1,
        posY   = properties.contentY + 5,
        width  = 30,
        height = 20,
        horizontallyCentered = true
    }, properties, "text_field")

    -- Page select
    properties:addComponent(Button, {
        posX   = -9,
        posY   = properties.contentY + 27,
        width  = 9,
        height = 1,
        text   = "Пред.",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:selectPreviousPage()
        end
    }, properties, "select_previous_page_button")

    properties:addComponent(TextField, {
        posY   = properties.contentY + 27,
        width  = 6,
        height = 1,
        text   = "1 из 1",
        centeredText = true,
        horizontallyCentered = true,
    }, properties, "page_info")

    properties:addComponent(Button, {
        posX   = 10,
        posY   = properties.contentY + 27,
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
        posY   = properties.contentY + 30,
        width  = 32,
        height = 1,
        text   = "Создать новую страницу",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:createPage()
        end
    }, properties, "create_page_button")

    properties:addComponent(Button, {
        posY   = properties.contentY + 32,
        width  = 32,
        height = 1,
        text   = "Очистить страницу",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:clearPage()
        end
    }, properties, "clear_page_button")

    properties:addComponent(Button, {
        posY   = properties.contentY + 34,
        width  = 32,
        height = 1,
        text   = "Удалить  страницу",
        horizontallyCentered = true,
        onTouchCallback = function()
            properties:deletePage()
        end
    }, properties, "delete_page_button")
    --

    properties:createDocument(properties, true)
end

function TextEditor:createBlankPage()
    local page = {
        lines      = {},
        properties = {}
    }
    for pageNum = 1, 20 do
        table.insert(page.lines, "")
        table.insert(page.properties, {
            color = 0x000000
        })
    end
    return page
end

function TextEditor:showConfirmation(text)
    return self:call(PopUp, {
        windowName = "Подтверждение",
        text = text,
        centeredText = true,
        type = "warning",
        doConfirmButtonRender = true,
        doDenyButtonRender    = true,
        doCloseButtonRender   = false
    })
end

function TextEditor:showError(text)
    return self:call(PopUp, {
        windowName = "Ошибка",
        text       = text,
        type       = "error",
        centeredText          = true,
        doConfirmButtonRender = true,
        confirmButtonText     = "Ок",
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

function TextEditor:showActionResult(isSuccess, text)
    local resultComponent = self:getComponent("document_action_result")
    resultComponent.textForegroundColor = isSuccess and constants.successTextColor or constants.errorTextColor
    resultComponent:updateText(text)

    -- Prevent unexpected clean of result
    local clock = os.clock()
    resultComponent.updateClock = clock

    local callback = function ()
        if resultComponent.updateClock == clock then
            resultComponent:updateText("")
        end
    end

    self:addEvent(event.timer(3, callback))
end

function TextEditor:debug()
    for key, value in pairs(self.pages[self.currentPage]) do
        gpu.setForeground(0xFFFFFF)
        gpu.set(1, key, "                                             ")
        gpu.set(1, key, key .. ": " .. value)
    end
    os.sleep(1)
end

function TextEditor:loadDocument(documentName, pages, properties)
    properties = properties or self
    properties.currentPage     = 1
    properties.pages           = {}
    properties.pagesProperties = {}

    for pageNum, pageData in pairs(pages) do
        table.insert(properties.pages, pageData.lines)
        table.insert(properties.pagesProperties, pageData.properties)
    end

    properties:getComponent("document_name_field"):updateLines({documentName})
    properties:showActionResult(true, "")
    properties:selectPage(properties.currentPage, true)
end

function TextEditor:createDocument(properties, skipConfirmation)
    properties = properties or self

    -- Ask user to confirm his action
    if not skipConfirmation then
        if not properties:showConfirmation("Вы уверены, что создать новый файл?\nВсе несохраненные изменения в текущем файле будут утеряны.") then
            return false
        end
    end

    properties:loadDocument("", { properties:createBlankPage() }, properties)

    return true
end

function TextEditor:openDocument()
    local result = self:call(Explorer, { allowDeletion = true }, self)

    if type(result) ~= "table" then
        return false
    end

    self:loadDocument(result.fileName:match("(.+)%."), result.data)

    return true
end

function TextEditor:saveDocument()
    local documentName = self:getComponent("document_name_field").lines[1]

    if documentName == "" then
        self:showWarning("Необходимо указать название файла")
        return false
    end

    documentName = documentName .. ".sdoc"

    if self.system.storage:exists(documentName) then
        if not self:showConfirmation("Вы уверены, что хотите перезаписать файл \"" .. documentName .. "\"?") then
            return false
        end
    end

    local documentData = {}
    for pageNum, pageData in pairs(self.pages) do
        table.insert(documentData, {
            lines      = pageData,
            properties = self.pagesProperties[pageNum]
        })
    end

    self:savePage()
    local result, error = self.system.storage:create(documentName, documentData)

    if error then
        self:showActionResult(false, "Ошибка: недостаточно памяти")
        return false
    end

    self:showActionResult(true, "Файл успешно сохранён")
    return true
end

function TextEditor:getPrinter()
    -- Check whether printer is available
    if not component.isAvailable("openprinter") then
        self:showError("Печать невозможна. Не установлен ни один принтер")
        return false;
    end

    return component.openprinter
end

function TextEditor:printDocument()
    self:savePage()

    local printer = self:getPrinter()
    if not printer then
        return false
    end

    local decision = self:call(PopUp, {
        windowName   = "Печать",
        text         = "Что вы желаете распечатать?",
        centeredText = true,
        doConfirmButtonRender = true,
        doDenyButtonRender    = true,
        doCloseButtonRender   = true,
        confirmButtonText     = "Текущую страницу",
        denyButtonText        = "Все страницы"
    })

    if decision == 0 then
        return false
    elseif decision then
        self:showActionResult(true, "Идет печать. Пожалуйста, подождите")
        self:printPage(printer, self.pages[self.currentPage])
        self:showActionResult(true, "Печать завершена")
        return true
    end

    for pageNum, pageLines in pairs(self.pages) do
        self:showActionResult(true, "Идет печать: " .. pageNum .. " страница из " .. #self.pages .. ". Пожалуйста, подождите")
        local isCancelled = not self:printPage(printer, pageLines)
        if isCancelled then
            self:showActionResult(true, "Печать отменена")
            return false
        end
    end

    self:showActionResult(true, "Печать завершена")
    return true
end

function TextEditor:defineErrorMessage(error)
    if error == "Please load Paper." then
        return "Печать невозможна. Пожалуйста, вставьте бумагу"
    elseif error == "Please load Ink." then
        return "Печать невозможна. Пожалуйста, заправьте картриджи с красками"
    elseif error == "No empty output slots." then
        return "Печать невозможна. Пожалуйста, заберите бумагу из переполненного лотка"
    end
    return "Печать невозможна. Произошла неизвестная ошибка"
end

function TextEditor:printPage(printer, pageLines)
    ::retry::
    printer.clear()

    for lineNum, line in pairs(pageLines) do
        printer.writeln(line)
    end

    local result, error = printer.print()
    if error then
        local decision = self:call(PopUp, {
            windowName   = "Ошибка",
            text         = self:defineErrorMessage(error),
            centeredText = true,
            type         = "error",
            doConfirmButtonRender = true,
            doDenyButtonRender    = true,
            doCloseButtonRender   = false,
            confirmButtonText     = "Продолжить печать",
            denyButtonText        = "Отменить печать"
        })

        if decision then
            goto retry
        end
        return false
    end

    return true
end

function TextEditor:selectPage(futurePage, skipSave)
    -- Check whether it's possible to change page
    if (futurePage < 1 or futurePage > #self.pages) then
        return false
    end

    -- Save current page in text editor
    if not skipSave then
        self:savePage()
    end

    -- Update text editor properties
    self.currentPage = futurePage

    -- Re-render component that tells current page
    self:getComponent("page_info"):updateText(self.currentPage .. " из " .. #self.pages)

    -- Update text in input field
    self:getComponent("text_field"):updateLines(self.pages[self.currentPage])

    return true
end

function TextEditor:selectNextPage(skipSave)
    return self:selectPage(self.currentPage + 1, skipSave)
end

function TextEditor:selectPreviousPage(skipSave)
    return self:selectPage(self.currentPage -1, skipSave)
end

function TextEditor:savePage()
    -- Save current page in text editor
    -- todo: save lines properties
    if self.pages[self.currentPage] then
        for key, string in pairs (self:getComponent("text_field").lines) do
            self.pages[self.currentPage][key] = string
        end
    end
end

function TextEditor:createPage()
    -- Check whether the document has reached maximum amount of pages
    local futurePage = #self.pages + 1
    if futurePage > self.MAX_PAGES then
        self:showWarning("Достигнуто максимальное количество страниц")
        return false
    end

    -- Create new blank page
    local page = self:createBlankPage()
    table.insert(self.pages, page.lines)
    table.insert(self.pagesProperties, page.properties)

    -- Open new page
    self:selectPage(futurePage)

    return true
end

function TextEditor:clearPage()
    -- Ask user to confirm his action
    if not self:showConfirmation("Вы уверены, что хотие очистить текущую страницу?") then
        return false
    end

    -- Clear current page
    local page = self:createBlankPage()
    self.pages[self.currentPage]           = page.lines
    self.pagesProperties[self.currentPage] = page.properties
    self:getComponent("text_field"):updateLines(self.pages[self.currentPage])

    return true
end

function TextEditor:deletePage()
    -- Check how many pages left and don't let do delete the last one
    if #self.pages <= 1 then
        self:showWarning("Вы не можете удалить последнюю оставшуюся страницу")
        return false
    end

    -- Ask user to confirm his action
    if not self:showConfirmation("Вы уверены, что хотие удалить текущую страницу?") then
        return false
    end

    -- Delete current page
    table.remove(self.pages, self.currentPage)
    table.remove(self.pagesProperties, self.currentPage)

    -- Open existing page (previous page is in priority)
    if not self:selectPage(self.currentPage, true) then
        if not self:selectPreviousPage(true) then
            -- Return critical error if text editor will fall into a stalemate
            error("Текстовый редактор зашёл в тупик с выбором страницы")
        end
    end

    return true
end

return TextEditor