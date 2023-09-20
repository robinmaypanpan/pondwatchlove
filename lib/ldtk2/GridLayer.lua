local class = require('middleclass')

local Layer = require('ldtk2.Layer')

-- Super class for all layers
local GridLayer = class('GridLayer', Layer)

function GridLayer:initialize(data, layerDefinition, level, tilesets)
    Layer.initialize(self, data,layerDefinition, level)

    self.tileSize = data.__gridSize

    -- Obtain the size of this grid
    self.numRows = data.__cHei
    self.numCols = data.__cWid
end

-- Sets the tile id at the specified row and column
function GridLayer:setTile(row,col,tileId)
end

-- Retrieves the tile at the indicated location
-- Returns the grid value at a given location
function GridLayer:getTile(row, col)
    local nullTile = {
        value = -1,
        tileId = -1,
        id = 'Missing',
        row = row,
        col = col,
        x = col * self.tileSize + self.level.x,
        y = row * self.tileSize + self.level.y,
        width = self.tileSize,
        height = self.tileSize
    }

    if row < 0 or col < 0 or row >= self.numRows or col >= self.numCols then
        return nullTile
    end

    if not self.tiles[row] then
        return nullTile
    end

    return self.tiles[row][col]
end

return GridLayer