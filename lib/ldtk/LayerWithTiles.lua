local class = require('lib/middleclass')

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
end

-- Returns a given tile
function LayerWithTiles:getTile(row, col)
    assert(false, 'getTile method not implemented in child class')
end

-- Returns the tile at the specified x,y level coordinates
function LayerWithTiles:getTileInLevel(x, y)
    local row = math.floor(y / self.tileSize)
    local col = math.floor(x / self.tileSize)

    return self:getTile(row, col)
end

-- Returns the tile at the specified x,y world coordinates
-- NB: Returns nil outside the level
function LayerWithTiles:getTileInWorld(x, y)
    return self:getTileInLevel(x - self.level.x, y - self.level.y)
end

-- Super function that should be overriden
function LayerWithTiles:draw()
    assert(false, 'draw method not implemented for child class')
end

return LayerWithTiles
