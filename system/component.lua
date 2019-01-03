--
-- Created by Ikamari, 02.01.2019 17:09
--

-- COS
local Object = require "system.main.object"

local Component = Object:inherit({
    posX = 1,
    poxY = 1
})

function Component:renderContent() end

function Component:render()
    self:renderContent()
end

return Component