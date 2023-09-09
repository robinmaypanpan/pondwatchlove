local class = require('lib/middleclass')

local PlayerComponent = class('PlayerComponent')

function PlayerComponent:initialize(player)
    self.player = player
end

-- Handles an update for the player
function PlayerComponent:update(updates)
end

-- Handles a change in level
function PlayerComponent:changeLevel(oldLevel, newLevel)
end

-- Draws anything for this player to the screen
function PlayerComponent:draw()
end

return PlayerComponent
