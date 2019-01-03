--
-- Created by Ikamari, 14.12.2018 23:34
--

-- COS
local Desktop   = require "system.desktop"
-- OOS
local process   = require "process"
local computer = require "computer"

-- Todo: uncomment when release version will be ready
--process.info().data.signal = function(...)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--    computer.beep(750, 0.02)
--end

local desktop = Desktop:new()
desktop:init()