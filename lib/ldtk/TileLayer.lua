local class = require('lib/middleclass')

local TileLayer = class('TileLayer')

function TileLayer:initialize(data, builder, level)
    self.level = level

    self.id = data.__identifier
    self.numRows = data.__cHei
    self.numCols = data.__cWid

    self.tileSize = data.__gridSize

    self.tileset = builder.tilesets[data.__tilesetDefUid]

    self.visible = data.visible
    self.opacity = data.__opacity

    self.tiles = {}

    local tiles

    if #data.autoLayerTiles > 0 then
        tiles = data.autoLayerTiles
    elseif #data.gridTiles > 0 then
        tiles = data.gridTiles
    end

    if tiles ~= nil and #tiles > 0 then
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
end

-- Draws this current tile layer
function TileLayer:draw()
    if self.tilesetBatch then
        self.tilesetBatch:clear()
        for _, tile in ipairs(self.tiles) do
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
        love.graphics.draw(self.tilesetBatch, self.level.x, self.level.y)
    end
end

return TileLayer
