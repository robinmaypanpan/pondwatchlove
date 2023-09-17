local class = require('middleclass')

-- Definition of a layer.  Does not contain actual data (most of the time)
local LayerDefinition = class('LayerDefinition')

function LayerDefinition:initialize(data)
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

return LayerDefinition