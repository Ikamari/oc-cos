--
-- Created by Ikamari, 14.12.2018 23:34
--

-- COS
local Desktop   = require "system.desktop"
local Config    = require "system.utillity.config"
-- OOS
local process   = require "process"
local computer  = require "computer"

-- Todo: uncomment when release version will be ready
--process.info().data.signal = function(...)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--end

--local config = Config:new()
--
--config:create("test", {one = "one", two = "two"})
--print("Created new config file")
--io.read()
--
--print("New config file values:")
--for k,v in pairs(config:get("test")) do print(k, "-->", v) end
--io.read()
--
--print("Updated config values in different ways")
--config:setValue("test", "one", 1)
--config:setValues("test", {two = 2, three = 3})
--io.read()
--
--print("Config file with updated values:")
--for k,v in pairs(config:get("test")) do print(k, "-->", v) end

local desktop = Desktop:new()
desktop:init()