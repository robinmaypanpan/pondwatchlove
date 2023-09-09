local class = require('lib/middleclass')

local Camp = class('Camp')

function Camp:initialize(data, level)
    self.level = level
    self.data = data

    self.x = data.__worldX
    self.y = data.__worldY
    self.width = data.width
    self.height = data.height
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
