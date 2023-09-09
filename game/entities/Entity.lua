local class = require('lib/middleclass')
local getFields = require('lib/ldtk/getFields')

local Entity = class('Entity')

function Entity:initialize(data, level)
    self.level = level
    self.data = data
    
    self.id = data.__identifier

    self.x = data.__worldX
    self.y = data.__worldY
    self.width = data.width
    self.height = data.height

    self.fields = getFields(data)
end

function Entity:update(updates, timeMultiplier)
end

function Entity:draw()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Entity
