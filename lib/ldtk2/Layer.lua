local class = require('middleclass')

local getFields = require('ldtk2.getFields')

-- Super class for all layers
local Layer = class('Layer')

function Layer:initialize(data, tilesets)
    self.id = data.__identifier
    self.uid = data.uid
    self.type = data.type

    self.opacity = data.displayOpacity

    -- Parallex interaction with camera for this player
    self.parallaxX = data.parallaxFactorX
    self.parallaxY = data.parallaxFactorY

    -- Indicates distance to offset this particular layer
    self.x = data.pxOffsetX
    self.y = data.pxOffsetY
end

-- Standard update function
function Layer:update(dt)
end

-- Standard draw function
function Layer:draw()
end

return Layer