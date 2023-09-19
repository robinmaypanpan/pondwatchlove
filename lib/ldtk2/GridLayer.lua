local class = require('middleclass')

local Layer = require('ldtk2.Layer')

-- Super class for all layers
local GridLayer = class('GridLayer', Layer)

function GridLayer:initialize(data, level, tilesets)
    Layer.initialize(self, data, level)

    self.tileSize = data.__gridSize

    -- Obtain the size of this grid
    self.numRows = data.__cHei
    self.numCols = data.__cWid
end

-- Sets the tile id at the specified row and column
function GridLayer:setTile(row,col,tileId)
end

-- Returns the tile at the specified row and column
function GridLayer:getTile(row,col)
end

return GridLayer