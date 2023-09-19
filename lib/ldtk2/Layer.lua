local class = require('middleclass')

local getFields = require('ldtk2.getFields')

-- Super class for all layers
local Layer = class('Layer')

function Layer:initialize(data, level)
    self.id = data.__identifier
    self.iid = data.iid
    self.uid = data.uid
    self.type = data.__type

    self.level = level

    self.opacity = data.__opacity

    -- Parallex interaction with camera for this player
    self.parallaxX = data.parallaxFactorX
    self.parallaxY = data.parallaxFactorY

    -- Indicates distance to offset this particular layer
    self.x = data.__pxTotalOffsetX
    self.y = data.__pxTotalOffsetY
end

-- Standard update function
function Layer:update(dt)
end

-- Standard draw function
function Layer:draw()
end

return Layer