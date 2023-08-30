local class = require('lib/middleclass')

local World = class('World')

function World:initialize(worldData)
    assert(worldData.worldLayout == 'GridVania')

    self.gridWidth = worldData.worldGridWidth
    self.gridHeight = worldData.worldGridHeight

    self.activeLevels = {}
    self.levels = {}
end

-- Adds the provided level data as an inactive level in the world
function World:addLevel(level)
    table.insert(self.levels, level)
end

-- Draws this level at the indicated position
function World:draw()
    for _, level in pairs(self.activeLevels) do
        level:draw()
    end
end

return World
