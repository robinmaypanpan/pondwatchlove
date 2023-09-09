local class = require('lib/middleclass')
local Entity = require('game/entities/Entity')

local Item = class('CarryComponent', Entity)

function Item:initialize(data, level)
    Entity.initialize(self, data, level)
    self.quad = data.quad
    self.tileset = data.tileset
end

function Item:update(updates)
end

function Item:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.tileset.imageSource, self.quad, self.x, self.y)
end

-- Returns a newly created item
function Item.generateItem(itemString, level)
    local itemEnumSet = builder.enumSets.Items
    local itemData = itemEnumSet[itemString]

    assert(itemData ~= nil, 'Invalid item string "' .. itemString .. '" provided to item generator')

    local item = Item:new(itemData, level)
    return item
end

return Item
