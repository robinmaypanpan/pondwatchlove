local class = require('lib/middleclass')

local ItemDispenser = class('ItemDispenser')

function ItemDispenser:initialize(data, level)
    self.level = level
    self.data = data

    self.x = data.__worldX
    self.y = data.__worldY
    self.width = data.width
    self.height = data.height

    local fields = {}

    for _, field in pairs(data.fieldInstances) do
        fields[field.__identifier] = field.__value
    end

    self.maxQuantity = fields.quantity
    self.quantity = fields.quantity

    self.item = fields.Items

    self.tileset = builder.tilesets[fields.fullTile.tilesetUid]
    self.tileQuad = self.tileset:getTileQuadByData(fields.fullTile)

    self.emptyTileset = builder.tilesets[fields.emptyTile.tilesetUid]
    self.emptyTileQuad = self.tileset:getTileQuadByData(fields.emptyTile)
end

function ItemDispenser:use(player)
    if self.quantity > 0 then
        self.quantity = self.quantity - 1
    end
end

function ItemDispenser:update(updates, timeMultiplier)
end

function ItemDispenser:draw()
    love.graphics.setColor(1, 1, 1, 1)
    if self.quantity > 0 then
        love.graphics.draw(self.tileset.imageSource, self.tileQuad, self.x, self.y)
    else
        love.graphics.draw(self.emptyTileset.imageSource, self.emptyTileQuad, self.x, self.y)
    end
end

return ItemDispenser
