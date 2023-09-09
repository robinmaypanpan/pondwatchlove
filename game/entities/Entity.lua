local class = require('lib/middleclass')
local getFields = require('lib/ldtk/getFields')

local Entity = class('Entity')

function Entity:initialize(data, level)
    self.level = level
    self.data = data

    self.id = data.__identifier

    self.x = data.__worldX or 0
    self.y = data.__worldY or 0
    self.width = data.width or 0
    self.height = data.height or 0

    self.fields = getFields(data)
end

function Entity:update(updates, timeMultiplier)
end

function Entity:draw()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
end

return Entity
