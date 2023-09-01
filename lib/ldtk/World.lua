local class = require('lib/middleclass')

local World = class('World')

function World:initialize(data)
    assert(data.worldLayout == 'GridVania')
    self.data = data

    self.levelWidth = data.defaultLevelWidth
    self.levelHeight = data.defaultLevelHeight

    self.activeLevels = {}

    self.levels = {}
end

-- Adds the provided level data as an inactive level in the world
function World:addLevel(level)
    self.levels[level.id] = level
end

function World:displayLevel(levelId)
    local level = self.levels[levelId]

    table.insert(self.activeLevels, level)
end

-- Draws this level at the indicated position
function World:draw()
    for _, level in pairs(self.activeLevels) do
        level:draw()
    end
end

return World
