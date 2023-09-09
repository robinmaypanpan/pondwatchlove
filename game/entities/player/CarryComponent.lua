local class = require('lib/middleclass')
local PlayerComponent = require('game/entities/player/PlayerComponent')

local CarryComponent = class('CarryComponent', PlayerComponent)

function CarryComponent:initialize(player)
    PlayerComponent.initialize(self, player)
    self.itemCarrying = nil
end

-- Returns true if the player is currently carrying an item
function CarryComponent:hasItem()
    return self.itemCarrying ~= nil
end

-- Picks up the provided item
function CarryComponent:pickupItem(itemEntity)
    self.itemCarrying = itemEntity
    itemEntity.x = self.player.x + self.player.width / 2 - itemEntity.width / 2
    itemEntity.y = self.player.y - itemEntity.height
end

-- Uses the item (currently just a stamina boost)
function CarryComponent:useItem()
    assert(self.itemCarrying ~= nil, 'Cannot use an item. None in hand')
    self.itemCarrying:unbindFromLevel()
    self.itemCarrying = nil
    self.player.stamina:boost(50)
end

function CarryComponent:update(updates)
    if self.itemCarrying then
        self.itemCarrying.x = self.player.x + self.player.width / 2 - self.itemCarrying.width / 2
        self.itemCarrying.y = self.player.y - self.itemCarrying.height
    end
end

function CarryComponent:changeLevel(oldLevel, newLevel)
    if self.itemCarrying then
        self.itemCarrying:unbindFromLevel()
        self.itemCarrying:bindToLevel(newLevel)
    end
end

return CarryComponent
