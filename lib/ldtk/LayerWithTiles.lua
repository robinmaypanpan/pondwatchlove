local class = require('middleclass')
local getFields = require('ldtk2.getFields')

-- Super class for layers that can contain tiles, including IntLayers and TileLayers
local LayerWithTiles = class('LayerWithTiles')

function LayerWithTiles:initialize(data, builder, level)
    self.level = level

    self.id = data.__identifier
    self.numRows = data.__cHei
    self.numCols = data.__cWid

    self.tileSize = data.__gridSize

    self.tileset = builder.tilesets[data.__tilesetDefUid]

    self.visible = data.visible
    self.opacity = data.__opacity

    self.layerDef = builder:getLayerDefinition(self.id)

    self.fields = getFields(data)
end

-- Ask for all the tiles between these two locations
function LayerWithTiles:getTilesInRange(row1, col1, row2, col2)
    local tiles = {}
    for row = row1, row2 do
        for col = col1, col2 do
            local tile = self:getTile(row, col)
            table.insert(tiles, tile)
        end
    end
    return tiles
end

-- Returns a given tile
function LayerWithTiles:getTile(row, col)
    assert(false, 'getTile method not implemented in child class')
end

-- Returns the tile at the specified x,y level coordinates
function LayerWithTiles:getTileInLevel(x, y)
    return self:getTile(self:convertLevelToGrid(x, y))
end

-- Returns the tile at the specified x,y world coordinates
-- NB: Returns nil outside the level
function LayerWithTiles:getTileInWorld(x, y)
    return self:getTileInLevel(self.level:convertWorldToLevel(x, y))
end

-- Converts level-relative x,y coordinates to row,col coordinates on the local grid
function LayerWithTiles:convertLevelToGrid(x, y)
    local row = math.floor(y / self.tileSize)
    local col = math.floor(x / self.tileSize)
    return row, col
end

-- Converts world-relative x,y coordinate to row,col coordinates on the local grid
function LayerWithTiles:convertWorldToGrid(x, y)
    return self:convertLevelToGrid(self.level:convertWorldToLevel(x, y))
end

-- Get the level-relative x,y coordinates of the provided row,col coordinates on the local grid
function LayerWithTiles:convertGridToLevel(row, col)
    local x = col * self.tileSize
    local y = row * self.tileSize
    return x, y
end

-- Get the world-relative x,y coordinates of the provided row,col coordinates on the local grid
function LayerWithTiles:convertGridToWorld(row, col)
    return self.level:convertLevelToWorld(self:convertGridToLevel(row, col))
end

-- Super function that should be overriden
function LayerWithTiles:draw()
    assert(false, 'draw method not implemented for child class')
end

return LayerWithTiles
