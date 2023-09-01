local class = require('lib/middleclass')

local TileLayer = class('TileLayer')

function TileLayer:initialize(data, builder)
    self.id = data.__identifier
    self.numRows = data.__cHei
    self.numCols = data.__cWid

    self.tileSize = data.__gridSize

    self.tileset = builder.tilesets[data.__tilesetDefUid]

    self.tiles = {}

    local tiles

    if #data.autoLayerTiles > 0 then
        tiles = data.autoLayerTiles
    elseif #data.gridTiles > 0 then
        tiles = data.gridTiles
    end

    for _, tileData in ipairs(tiles) do
        local tile = {
            id = tileData.t,
            sourceLocation = { x = tileData.src[1], y = tileData.src[2] },
            drawLocation = { x = tileData.px[1], y = tileData.px[2] },
            flipX = tileData.f == 1 or tileData.f == 3,
            flipY = tileData.f == 2 or tileData.f == 3,
            opacity = tileData.a,
            data = tileData
        }

        tile.quad = self.tileset:getTileQuad(tile.id)

        table.insert(self.tiles, tile)
    end

    self.tilesetBatch = self.tileset:createSpriteBatch(self.numRows, self.numCols)
end

-- returns a drawable for this layer representing its current state
function TileLayer:renderDrawable()
    self.tilesetBatch:clear()
    for _, tile in ipairs(self.tiles) do
        self.tilesetBatch:add(tile.quad, tile.drawLocation.x, tile.drawLocation.y)
    end
    self.tilesetBatch:flush()
    return self.tilesetBatch
end

return TileLayer
