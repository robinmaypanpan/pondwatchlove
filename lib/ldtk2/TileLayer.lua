local class = require('middleclass')

local GridLayer = require('ldtk2.GridLayer')

-- Super class for all layers
local TileLayer = class('TileLayer', GridLayer)

function TileLayer:initialize(data, tilesets)
    GridLayer.initialize(self, data, tilesets)
end

return TileLayer