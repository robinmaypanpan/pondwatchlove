local class = require('lib/middleclass')
local Entity = require('game/entities/Entity')
local Item = require('game/entities/Item')

local ItemDispenser = class('ItemDispenser', Entity)

function ItemDispenser:initialize(data, level)
    Entity.initialize(self, data, level)
    self.maxQuantity = self.fields.quantity
    self.quantity = self.fields.quantity

    self.item = self.fields.Items

    self.tileset = builder.tilesets[self.fields.fullTile.tilesetUid]
    self.tileQuad = self.tileset:getTileQuadByData(self.fields.fullTile)

    self.emptyTileset = builder.tilesets[self.fields.emptyTile.tilesetUid]
    self.emptyTileQuad = self.tileset:getTileQuadByData(self.fields.emptyTile)
end

function ItemDispenser:use(player)
    if self.quantity > 0 and not player.carry:hasItem() then
        self.quantity = self.quantity - 1
        local item = Item.generateItem(self.item, self.level)
        local entityLayer = self.level:getLayer('Entities')
        entityLayer:bindEntity(item)
        player.carry:pickupItem(item)
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
