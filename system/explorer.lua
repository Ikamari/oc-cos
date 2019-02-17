-- InfOS
local BasicApp   = require "system.app"
local PopUp      = require "system.popup"
local Line       = require "system.components.common.line"
-- Components
local Button     = require "system.components.common.Button"
local TextField  = require "system.components.common.textField"
-- OpenOS
local component = require "component"
local gpu       = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

---@class Explorer : BasicApp
local Explorer = BasicApp:inherit({
    windowName   = "Проводник",
    windowX      = screenWidth  * 0.3,
    windowWidth  = screenWidth  * 0.4,

    autoSize     = false,

    blinkOnMiss  = true,

    maxFilesPerPage = 10
})

---@param properties Explorer
function Explorer:constructor(properties, parameters)
    -- Define which properties must be used (Needed for child classes that calls parent constructor)
    properties = properties or self
    parameters = parameters or {}

    properties.windowHeight = 7 + ((properties.maxFilesPerPage + 1) * 2)
    properties.windowY      = math.ceil((screenHeight - properties.windowHeight) / 2)

    -- Call parent constructor
    BasicApp:constructor(properties, parameters)

    properties.windowName       = parameters.windowName or properties.windowName
    properties.filter           = parameters.filter
    properties.allowDeletion    = parameters.allowDeletion or false

    properties.title            = parameters.title           or "Выберите файл:"
    properties.notFoundMessage  = parameters.notFoundMessage or "Файлы не найдены"

    properties.currentPage = 1
    properties:getFiles()
    properties:prepareComponents()
end

function Explorer:getFiles(properties)
    properties = properties or self
    properties.files = self.system.storage:list(properties.filter)
    properties.pages = {{}}

    for _, fileName in pairs(properties.files) do
        if #(properties.pages[#properties.pages]) >= 10 then
            table.insert(properties.pages, {})
        end
        table.insert(properties.pages[#properties.pages], fileName)
    end
end

function Explorer:prepareComponents(properties)
    properties            = properties or self
    properties.components = {}

    while not properties.pages[properties.currentPage] do
        properties.currentPage = properties.currentPage - 1
    end
    local files = properties.pages[properties.currentPage]

    -- Title or info about empty page
    if #files == 0 then
        properties:addComponent(TextField, {
            width  = properties.contentWidth,
            height = 2,
            text   = properties.notFoundMessage,
            centeredText = true,
            horizontallyCentered = true,
            verticallyCentered   = true
        }, properties, "no_files_error")
        return true
    end

    properties:addComponent(TextField, {
        posX   = properties.contentX,
        posY   = properties.contentY,
        width  = properties.contentWidth,
        height = 1,
        text   = properties.title,
        centeredText = true
    }, properties, "title")

    properties:addComponent(Line, {
        orientation = "horizontal",
        posX   = properties.contentX,
        posY   = properties.contentY + 1,
        width  = properties.contentWidth
    }, properties)

    -- Files
    for key, fileName in pairs(files) do
        properties:addComponent(TextField, {
            posX   = properties.contentX,
            posY   = properties.contentY + 1 + (key * 2),
            width  = properties.contentWidth - 26,
            height = 1,
            text   = fileName
        }, properties, "file_" .. key .. "_name")

        properties:addComponent(Button, {
            text   = "Открыть",
            posX   = properties.allowDeletion and (properties.contentX + properties.contentWidth - 23) or (properties.contentX + properties.contentWidth - 11),
            posY   = properties.contentY + 1 + (key * 2),
            width  = 11,
            height = 1,
            onTouchCallback = function()
                properties:returnFile(fileName)
            end
        }, properties, "open_file_" .. key .. "_button")

        if properties.allowDeletion then
            properties:addComponent(Button, {
                text   = "Удалить",
                posX   = properties.contentX + properties.contentWidth - 11,
                posY   = properties.contentY + 1 + (key * 2),
                width  = 11,
                height = 1,
                onTouchCallback = function()
                    properties:deleteFile(fileName)
                end
            }, properties, "delete_file_" .. key .. "_button")
        end
    end

    properties:addComponent(Line, {
        orientation = "horizontal",
        posX   = properties.contentX,
        posY   = properties.contentY + properties.contentHeight - 2,
        width  = properties.contentWidth
    }, properties)

    -- Page controls
    if properties.currentPage > 1 then
        properties:addComponent(Button, {
            posX   = -9,
            posY   = properties.contentY + properties.contentHeight - 1,
            width  = 9,
            height = 1,
            text   = "Пред.",
            horizontallyCentered = true,
            onTouchCallback = function()
                properties:selectPreviousPage()
            end
        }, properties, "select_previous_page_button")
    end

    properties:addComponent(TextField, {
        posY   = properties.contentY + properties.contentHeight - 1,
        width  = 6,
        height = 1,
        text   = properties.currentPage .. " из " .. #properties.pages,
        centeredText = true,
        horizontallyCentered = true,
    }, properties, "page_info")

    if properties.currentPage < #properties.pages then
        properties:addComponent(Button, {
            posX   = 10,
            posY   = properties.contentY + properties.contentHeight - 1,
            width  = 9,
            height = 1,
            text   = "След.",
            horizontallyCentered = true,
            onTouchCallback = function()
                properties:selectNextPage()
            end
        }, properties, "select_next_page_button")
    end

    return true
end

function Explorer:selectPage(futurePage)
    -- Check whether it's possible to change page
    if (futurePage < 1 or futurePage > #self.pages) then
        return false
    end

    -- Update text editor properties
    self.currentPage = futurePage

    -- Re-render window
    self:prepareComponents()
    self:render()

    return true
end

function Explorer:selectNextPage()
    return self:selectPage(self.currentPage + 1)
end

function Explorer:selectPreviousPage()
    return self:selectPage(self.currentPage -1)
end

function Explorer:returnFile(fileName)
    self:terminate({
        fileName = fileName,
        data     = self.system.storage:get(fileName)
    })
end

function Explorer:showConfirmation(fileName)
    return self:call(PopUp, {
        windowName = "Подтверждение",
        text = "Вы уверены, что хотите удалить \"" .. fileName .. "\"?",
        centeredText = true,
        type = "warning",
        doConfirmButtonRender = true,
        doDenyButtonRender    = true,
        doCloseButtonRender   = false
    }, self, "first_parent")
end

function Explorer:deleteFile(fileName)
    if not self:showConfirmation(fileName) then
        return false
    end

    if self.system.storage:exists(fileName) then
        self.system.storage:remove(fileName)
        -- Re-render window
        self:getFiles()
        self:prepareComponents()
        self:render()
    end

    return true
end

return Explorer