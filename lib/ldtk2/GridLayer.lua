local class = require('middleclass')

local Layer = require('ldtk2.Layer')

-- Super class for all layers
local GridLayer = class('GridLayer', Layer)

function GridLayer:initialize(data, tilesets)
    Layer.initialize(self, data, tilesets)

    self.tileSize = data.gridSize
    self.tileset = tilesets[data.tilesetDefUid]
end

-- Sets the tile id at the specified row and column
function GridLayer:setTile(row,col,tileId)
end

-- Returns the tile at the specified row and column
function GridLayer:getTile(row,col)
end

return GridLayer