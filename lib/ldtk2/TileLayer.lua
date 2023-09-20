local class = require('middleclass')

local GridLayer = require('ldtk2.GridLayer')

-- Super class for all layers
local TileLayer = class('TileLayer', GridLayer)

function TileLayer:initialize(data, layerDefinition, level, tilesets)
    GridLayer.initialize(self, data, layerDefinition, level, tilesets)

    self.tileset = tilesets[data.__tilesetDefUid]

    -- Order to draw tiles in
    self.drawTiles = {}
    self.tiles = {}

    local tiles = {}

    if #data.autoLayerTiles > 0 then
        tiles = data.autoLayerTiles
    elseif #data.gridTiles > 0 then
        tiles = data.gridTiles
    end

    for _, tileData in ipairs(tiles) do
        local tileRow = math.floor(tileData.px[2] / self.tileSize)
        local tileCol = math.floor(tileData.px[1] / self.tileSize)

        assert(tileRow < self.numRows, "Invalid row for tile")
        assert(tileCol < self.numCols, "Invalid col for tile")

        local tile = {
            tileId = tileData.t,
            sourceLocation = { x = tileData.src[1], y = tileData.src[2] },
            x = tileData.px[1],
            y = tileData.px[2],
            row = tileRow,
            col = tileCol,
            flipX = tileData.f == 1 or tileData.f == 3,
            flipY = tileData.f == 2 or tileData.f == 3,
            opacity = tileData.a,
            data = tileData,
            width = self.tileSize,
            height = self.tileSize
        }

        tile.quad = self.tileset:getTileQuad(tileData.t)
        
        if not self.tiles[tileRow] then
            self.tiles[tileRow] = {}
        end

        self.tiles[tileRow][tileCol] = tile
        table.insert(self.drawTiles, {row=tileRow, col=tileCol})
    end

    self.tilesetBatch = self.tileset:createSpriteBatch(self.numRows, self.numCols)

end

function TileLayer:renderTileToSpriteBatch(row,col, spriteBatch)
    local tile = self:getTile(row, col)
    assert(tile ~= nil, "Tile does not exist at "..row..", "..col)
    assert(tile.tileId ~= -1, "Tile does not have rendering data at "..row..", "..col .. " for layer " .. self.id .. " on level " .. self.level.id)
    local scaleX = 1
    local scaleY = 1
    if tile.flipX then
        scaleX = -1
    end
    if tile.flipY then
        scaleY = -1
    end
    spriteBatch:add(tile.quad, tile.x, tile.y, 0, scaleX, scaleY)
end

-- Draws this current tile layer
function TileLayer:draw()
    if self.tilesetBatch then
        self.tilesetBatch:clear()
        for _, tilePosition in ipairs(self.drawTiles) do
            self:renderTileToSpriteBatch(tilePosition.row, tilePosition.col, self.tilesetBatch)
        end
        self.tilesetBatch:flush()
        love.graphics.setColor(1, 1, 1, self.opacity)
        love.graphics.draw(self.tilesetBatch, self.level.x, self.level.y)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return TileLayer