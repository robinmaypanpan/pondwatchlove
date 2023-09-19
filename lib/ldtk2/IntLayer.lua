local class = require('middleclass')

local GridLayer = require('ldtk2.GridLayer')

-- Super class for all layers
local IntLayer = class('IntLayer', GridLayer)

function IntLayer:initialize(data, level, tilesets)
    GridLayer.initialize(self, data, level, tilesets)
end

return IntLayer