local class = require('lib/middleclass')
local Entity = require('game/entities/Entity')

local Camp = class('Camp', Entity)

function Camp:initialize(data, level)
    Entity.initialize(self, data, level)
end

function Camp:use(player)
    player.stamina:reset()
    player.respawn:setNewCamp(self)
end

function Camp:update(updates, timeMultiplier)
end

function Camp:draw()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Camp
