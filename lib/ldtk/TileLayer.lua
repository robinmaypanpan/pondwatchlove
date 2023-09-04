local class = require('lib/middleclass')

local LayerWithTiles = require('lib/ldtk/LayerWithTiles')

local TileLayer = class('TileLayer', LayerWithTiles)

function TileLayer:initialize(data, builder, level)
    LayerWithTiles.initialize(self, data, builder, level)
    self.drawTiles = {}
    self.tiles = {}

    local tiles = {}

    if #data.autoLayerTiles > 0 then
        tiles = data.autoLayerTiles
    elseif #data.gridTiles > 0 then
        tiles = data.gridTiles
    end

    for _, tileData in ipairs(tiles) do
        local tile = {
            tileId = tileData.t,
            sourceLocation = { x = tileData.src[1], y = tileData.src[2] },
            drawLocation = { x = tileData.px[1], y = tileData.px[2] },
            flipX = tileData.f == 1 or tileData.f == 3,
            flipY = tileData.f == 2 or tileData.f == 3,
            opacity = tileData.a,
            data = tileData
        }

        tile.quad = self.tileset:getTileQuad(tileData.t)

        table.insert(self.drawTiles, tile)

        local tileRow = math.floor(tileData.src[2] / self.numRows)
        local tileCol = math.floor(tileData.src[1] / self.numCols)

        if not self.tiles[tileRow] then
            self.tiles[tileRow] = {}
        end

        self.tiles[tileRow][tileCol] = tile
    end

    self.tilesetBatch = self.tileset:createSpriteBatch(self.numRows, self.numCols)
end

-- Retrieves the tile at the indicated location
-- Returns the grid value at a given location
function TileLayer:getTile(row, col)
    if row < 0 or col < 0 or row >= self.numRows or col >= self.numCols then
        return nil
    end

    if not self.tiles[row] then
        return nil
    end

    return self.tiles[row][col]
end

-- Draws this current tile layer
function TileLayer:draw()
    if self.tilesetBatch then
        self.tilesetBatch:clear()
        for _, tile in ipairs(self.drawTiles) do
            local scaleX = 1
            local scaleY = 1
            if tile.flipX then
                scaleX = -1
            end
            if tile.flipY then
                scaleY = -1
            end
            self.tilesetBatch:add(tile.quad, tile.drawLocation.x, tile.drawLocation.y, 0, scaleX, scaleY)
        end
        self.tilesetBatch:flush()
        love.graphics.setColor(1, 1, 1, self.opacity)
        love.graphics.draw(self.tilesetBatch, self.level.x, self.level.y)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return TileLayer
