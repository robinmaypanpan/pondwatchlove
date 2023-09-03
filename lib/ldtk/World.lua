local class = require('lib/middleclass')

-- The World class contains a definition of the world and all its levels
-- It can be used to activate and deactivate certain levels from the world
local World = class('World')

function World:initialize(data)
    self.data = data

    self.levelWidth = data.defaultLevelWidth
    self.levelHeight = data.defaultLevelHeight

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
function World:activateLevel(levelId)
    local level = self.levels[levelId]
    assert(level ~= nil, 'Level ' .. levelId .. ' not found')

    table.insert(self.activeLevels, level)

    --Now activate neighbors
    for _, neighborData in ipairs(level.neighbors) do
        local neighborLevel = self.levels[neighborData.levelIid]
        assert(neighborLevel ~= nil, 'Could not find neighboring level')
        table.insert(self.activeLevels, neighborLevel)
    end
end

-- Removes a given level from the activated level list
function World:deactivateLevel(levelId)
    local level = self.levels[levelId]

    assert(level ~= nil, 'Level ' .. levelId .. ' not found')
    local index = table.find(self.activeLevels, level)
    table.remove(self.activeLevels, index)
end

-- Draws this level
function World:draw()
    for _, level in ipairs(self.activeLevels) do
        level:draw()
    end
end

return World
