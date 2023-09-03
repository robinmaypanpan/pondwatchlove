local class = require('lib/middleclass')

-- The World class contains a definition of the world and all its levels
-- It can be used to activate and deactivate certain levels from the world
local World = class('World')

function World:initialize(data)
    self.data = data

    self.levelWidth = data.worldGridWidth
    self.levelHeight = data.worldGridHeight

    self.activeLevels = {}

    self.levels = {}
end

-- Adds the provided level data as an inactive level in the world
function World:addLevel(level)
    self.levels[level.id] = level
    self.levels[level.iid] = level
    self.levels[level.uid] = level
end

-- Sets the indicated level as a level to display
function World:setActiveLevel(levelId)
    local level = self.levels[levelId]
    assert(level ~= nil, 'Level ' .. levelId .. ' not found')

    self.activeLevels = {}

    table.insert(self.activeLevels, level)

    --Now activate neighbors
    for _, neighborData in ipairs(level.neighbors) do
        local neighborLevel = self.levels[neighborData.levelIid]
        assert(neighborLevel ~= nil, 'Could not find neighboring level')
        table.insert(self.activeLevels, neighborLevel)
    end
end

-- Returns a level at a given location, checking active levels first
function World:getLevelAt(x, y)
    for _, level in pairs(self.activeLevels) do
        if level:isWithinLevel(x, y) then
            return level
        end
    end

    return nil
end

-- Draws this level
function World:draw()
    for _, level in ipairs(self.activeLevels) do
        level:draw()
    end
end

return World
