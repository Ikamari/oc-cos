-- InfOS
local Disk         = require "system.managers.disks.disk"
-- Helpers
local StringHelper = require "system.helpers.stringHelper"
-- OpenOS
local computer     = require "computer"
local component    = require "component"
local gpu          = component.gpu
local screenWidth, screenHeight = gpu.getResolution()

---@class DisposableHackTool : Disk
local DisposableHackTool = Disk:inherit({
    autorun            = true,
    runWhenLoggedIn    = true,
    runWhenNotLoggedIn = true,
    visibleInDesktop   = false
})

function DisposableHackTool:whenNotLoggedIn()
    if self.system.config:get("startup", "doFirstLaunchProcedure") then
        return false
    end

    if self.system.config:get("user", "password") == "" then
        return false
    end

    self.system.isUnrecoverable = true

    -- Render some "hacking" stuff
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, screenWidth, screenHeight, " ")
    self:renderStartup()

    -- Check whether disk is still in drive
    self.system.drive:check(self.system.drive.diskAddress)
    if (self.system.drive.diskType ~= "disposable_hack_tool") then
        computer.beep(750, 0.02)
        gpu.set(2, 7, "> Взлом отменён")
        os.sleep(3)
        error("unknown error")
    end

    -- Remove instruction from drive
    self.system.file:remove("/mnt/" .. self.system.drive.diskShortAddress .. "/instruction.dat")

    -- Render some "hacking" stuff
    self:renderHackedAddresses()
    os.sleep(2)

    -- Reset password
    self.system.config:setValue("user", "password", "")

    -- Force BSOD
    error("memory corrupted")
end

function DisposableHackTool:renderStartup()
    os.sleep(3)
    computer.beep(750, 0.02)
    self:renderLoadingLine(2, "> Идёт проверка системы", 3)
    computer.beep(750, 0.02)
    gpu.set(2, 3, "> Уязвимость обнаружена")
    os.sleep(1)
    computer.beep(750, 0.02)
    self:renderLoadingLine(4, "> Идёт поиск необходимого сегмента памяти", 5)
    computer.beep(750, 0.02)
    gpu.set(2, 5, "> Сегмент памяти обнаружен")
    os.sleep(1)
    computer.beep(750, 0.02)
    self:renderLoadingLine(6, "> Подготовка к взлому системы", 2)
end

function DisposableHackTool:renderLoadingLine(posY, string, time)
    local stringLength = StringHelper:getLength(string)
    gpu.set(2, posY, string)
    for i = 0, time - 1, 1 do
        gpu.set(stringLength + 2, posY, ".")
        os.sleep(0.25)
        gpu.set(stringLength + 2, posY, "..")
        os.sleep(0.25)
        gpu.set(stringLength + 2, posY, "...")
        os.sleep(0.25)
        gpu.set(stringLength + 2, posY, "   ")
        os.sleep(0.25)
    end
end

function DisposableHackTool:renderHackedAddresses()
    local randomDigit  = 5000000 + math.floor(math.random() * 10000000)
    local address      = randomDigit - (randomDigit % 16)
    for i = 0, 30 do
        local line = "0" .. string.upper(string.format("%x", address)) .. ": "
        for j = 0, 31 do
            line = line .. string.upper(string.format("%x", 16 + math.floor(math.random() * 239))) .. " "
            if (j + 1) % 4 == 0 then
                line = line .. " "
            end
            if (j + 1) - 16 == 0 then
                line = line .. ">  "
            end
        end
        os.sleep(0.001)
        gpu.set(4, 8 + i, line)
        address = address + 16
    end
end

return DisposableHackTool

