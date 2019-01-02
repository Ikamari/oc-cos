--
-- Created by Ikamari, 14.12.2018 23:34
--

local Desktop  = require "desktop"
local process  = require "process"
local computer = require("component").computer

-- Todo: uncomment when release version will be ready
--process.info().data.signal = function(...)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--end

local desktop = Desktop:new()
desktop:init()