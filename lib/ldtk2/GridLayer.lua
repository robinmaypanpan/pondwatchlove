local class = require('middleclass')

local Layer = require('ldtk2.Layer')

-- Super class for all layers
local GridLayer = class('GridLayer', Layer)

function GridLayer:initialize(data, tilesets)
    Layer.initialize(self, data)

    self.tileSize = data.gridSize
    self.tileset = tilesets[data.tilesetDefUid]
end

return GridLayer