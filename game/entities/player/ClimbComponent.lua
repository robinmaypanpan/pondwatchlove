local class = require('lib/middleclass')
local PlayerComponent = require('game/entities/player/PlayerComponent')

local Tiles = require('game/Tiles')

local ClimbComponent = class('ClimbComponent', PlayerComponent)

function ClimbComponent:initialize(player)
    PlayerComponent.initialize(self, player)
    self.isClimbing = false
end

-- Returns the nearest climbable tile in range
function ClimbComponent:getNearestClimbable()
    local player = self.player

    local collisionLayer = player.level:getLayer('Collision')

    local results = player:getPlayerTiles()

    local centerRow, centerCol = collisionLayer:convertWorldToGrid(player.x + player.width / 2,
        player.y + player.height / 2)

    local selectedTile = {
        tile = nil,
        distance = 99999
    }

    for _, tile in ipairs(results) do
        if Tiles.isClimbable(tile) then
            local distance = math.distance(centerRow, centerCol, tile.row, tile.col)
            if distance < selectedTile.distance then
                selectedTile =
                {
                    tile = tile,
                    distance = distance
                }
            end
        end
    end

    return selectedTile.tile
end

function ClimbComponent:isAtTopOfClimbable(tile)
    local collisionLayer = player.level:getLayer('Collision')
    local tileAbove = collisionLayer:getTile(tile.row - 1, tile.col)
    return self.player.y + self.player.height == tile.y
        and not Tiles.isClimbable(tileAbove)
end

function ClimbComponent:update(updates, timeMultiplier)
    local player = self.player

    local climbSpeed = player.fields.climbSpeed

    local collisionLayer = player.level:getLayer('Collision')
    local climbableTile = self:getNearestClimbable()

    if climbableTile == nil then
        -- Cancel all climbing and stop trying
        self.isClimbing = false
        return
    end

    if updates.moveUp and not self:isAtTopOfClimbable(climbableTile) then
        -- Start Climbing up a climbable
        player.x = climbableTile.x + collisionLayer.tileSize / 2 - player.width / 2
        player:setXSpeed(0)
        player:changeYSpeed(-climbSpeed, timeMultiplier)
        self.isClimbing = true
    elseif updates.moveDown then
        -- Start climbing down a climbable
        player.x = climbableTile.x + collisionLayer.tileSize / 2 - player.width / 2
        player:setXSpeed(0)
        player:changeYSpeed(climbSpeed, timeMultiplier)
        self.isClimbing = true
    elseif updates.jump then
        self.isClimbing = false
        -- Allow jump/falling to occur
    elseif self.isClimbing then
        -- Stopping while on a climbable
        player:setYSpeed(0)
    end
end

return ClimbComponent
