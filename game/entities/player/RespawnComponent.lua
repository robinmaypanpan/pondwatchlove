local class = require('lib/middleclass')
local PlayerComponent = require('game/entities/player/PlayerComponent')

local RespawnComponent = class('RespawnComponent', PlayerComponent)

function RespawnComponent:initialize(player)
    PlayerComponent.initialize(self, player)
    self.x = player.x
    self.y = player.y
    self.level = player.level
end

function RespawnComponent:setNewCamp(camp)
    self.x = camp.x
    self.y = camp.y
    self.level = camp.level
end

function RespawnComponent:update(updates)
    if self.player.stamina.stamina <= 0 then
        self.player:changeLevels(self.level)
        self.player.x = self.x
        self.player.y = self.y
        self.player.stamina:reset()
    end
end

return RespawnComponent
