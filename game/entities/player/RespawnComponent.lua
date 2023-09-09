local class = require('lib/middleclass')

local RespawnComponent = class('RespawnComponent')

function RespawnComponent:initialize(player)
    self.player = player
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

function RespawnComponent:draw()
end

return RespawnComponent
