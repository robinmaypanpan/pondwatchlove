local class = require('lib/middleclass')

local CarryComponent = class('CarryComponent')

function CarryComponent:initialize(player)
    self.player = player
    self.itemCarrying = nil
end

-- Returns true if the player is currently carrying an item
function CarryComponent:hasItem()
    return self.itemCarrying ~= nil
end

function CarryComponent:pickupItem(itemEntity)
    self.itemCarrying = itemEntity
    itemEntity.x = self.player.x + self.player.width / 2 - itemEntity.width / 2
    itemEntity.y = self.player.y - itemEntity.height
end

function CarryComponent:update(updates)
    if self.itemCarrying then
        self.itemCarrying.x = self.player.x + self.player.width / 2 - self.itemCarrying.width / 2
        self.itemCarrying.y = self.player.y - self.itemCarrying.height
    end
end

function CarryComponent:draw()
end

return CarryComponent
