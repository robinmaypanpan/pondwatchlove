local class = require('lib/middleclass')
local Entity = require('game/entities/Entity')

local Player = class('Player', Entity)

local Tiles = require('game/Tiles')

local StaminaComponent = require('game/entities/player/StaminaComponent')
local AnimationComponent = require('game/entities/player/AnimationComponent')
local RespawnComponent = require('game/entities/player/RespawnComponent')
local UseableComponent = require('game/entities/player/UseableComponent')
local CarryComponent = require('game/entities/player/CarryComponent')
local JumpComponent = require('game/entities/player/JumpComponent')
local ClimbComponent = require('game/entities/player/ClimbComponent')
local MoveComponent = require('game/entities/player/MoveComponent')

local CollisionType = {
    None = 0,
    Wall = 1,
    OutsideLevel = 2
}

function Player:initialize(data, level)
    Entity.initialize(self, data, level)

    self.jumpStart = self.y

    self.xSpeed = 0
    self.ySpeed = 0

    self.flipImage = false

    self.currentGravity = 0

    -- Create our sub components
    self.components = {}

    self.stamina = StaminaComponent:new(self)
    table.insert(self.components, self.stamina)

    self.animation = AnimationComponent:new(self)
    table.insert(self.components, self.animation)

    self.respawn = RespawnComponent:new(self)
    table.insert(self.components, self.respawn)

    table.insert(self.components, UseableComponent:new(self))

    self.carry = CarryComponent:new(self)
    table.insert(self.components, self.carry)

    self.jump = JumpComponent:new(self)
    table.insert(self.components, self.jump)

    self.climb = ClimbComponent:new(self)
    table.insert(self.components, self.climb)

    self.move = MoveComponent:new(self)
    table.insert(self.components, self.move)

    self.width = self.animation.width
    self.height = self.animation.height
end

-- Returns a list of the tiles that are currently below the player's feet, assuming the player is at x,y
-- Only returns actual tiles and not non-empty tiles
function Player:getGroundTiles(x, y)
    local collisionLayer = self.level:getLayer('Collision')

    local lowerRightRow, lowerRightCol = collisionLayer:convertWorldToGrid(x + self.width, y + self.height)
    local lowerLeftRow, lowerLeftCol = collisionLayer:convertWorldToGrid(x, y + self.height)

    -- Get all the tiles below the player
    local results = collisionLayer:getTilesInRange(lowerLeftRow, lowerLeftCol, lowerRightRow, lowerRightCol)

    local finalResults = {}

    -- Look through all the tiles to make sure there's nothing above them.
    for _, tile in ipairs(results) do
        local tileAbove = collisionLayer:getTile(tile.row - 1, tile.col)
        if Tiles.isImpassable(tileAbove) or Tiles.isEmpty(tile) then
        else
            table.insert(finalResults, tile)
        end
    end

    return finalResults
end

-- Get a hitbox assuming the player is at x,y
function Player:getHitbox(x, y)
    local hitboxSize = self.fields.hitboxSize

    local hitbox = {
        x = x + self.width / 2 - hitboxSize / 2,
        y = y + self.height / 2 - hitboxSize / 2,
        width = hitboxSize,
        height = hitboxSize
    }

    hitbox.top = hitbox.y
    hitbox.left = hitbox.x
    hitbox.right = hitbox.x + hitbox.width
    hitbox.bottom = hitbox.y + hitbox.height

    return hitbox
end

-- Return all the tiles around the player
function Player:getPlayerTiles(x, y)
    local collisionLayer = self.level:getLayer('Collision')

    local hitbox = self:getHitbox(self.x, self.y)

    local upperLeftRow, upperLeftCol = collisionLayer:convertWorldToGrid(hitbox.x, hitbox.y)
    local lowerRightRow, lowerRightCol = collisionLayer:convertWorldToGrid(hitbox.right, hitbox.bottom)

    return collisionLayer:getTilesInRange(upperLeftRow, upperLeftCol, lowerRightRow, lowerRightCol)
end

-- Returns a list of tiles on the edge of the player
function Player:getEdgeTiles(direction, distance)
    local collisionLayer = self.level:getLayer('Collision')

    local newX = self.x
    local newY = self.y

    if direction == 'x' then
        newX = newX + distance
    elseif direction == 'y' then
        newY = newY + distance
    end

    local hitbox = self:getHitbox(newX, newY)

    local upperLeftRow, upperLeftCol = collisionLayer:convertWorldToGrid(hitbox.left, hitbox.top)
    local upperRightRow, upperRightCol = collisionLayer:convertWorldToGrid(hitbox.right, hitbox.top)
    local lowerRightRow, lowerRightCol = collisionLayer:convertWorldToGrid(hitbox.right, hitbox.bottom)
    local lowerLeftRow, lowerLeftCol = collisionLayer:convertWorldToGrid(hitbox.left, hitbox.bottom)

    local results = {}
    if direction == 'x' and distance > 0 then
        results = collisionLayer:getTilesInRange(upperRightRow, upperRightCol, lowerRightRow, lowerRightCol)
    elseif direction == 'x' and distance < 0 then
        results = collisionLayer:getTilesInRange(upperLeftRow, upperLeftCol, lowerLeftRow, lowerLeftCol)
    elseif direction == 'y' and distance > 0 then
        results = collisionLayer:getTilesInRange(lowerLeftRow, lowerLeftCol, lowerRightRow, lowerRightCol)
    elseif direction == 'y' and distance < 0 then
        results = collisionLayer:getTilesInRange(upperLeftRow, upperLeftCol, upperRightRow, upperRightCol)
    end

    return results
end

-- Check for collisions in all the right places
function Player:checkForCollisions(direction, distance)
    local results = self:getEdgeTiles(direction, distance)

    for _, tile in ipairs(results) do
        if Tiles.isImpassable(tile) then
            return {
                type = CollisionType.Wall
            }
        end
    end

    for _, tile in ipairs(results) do
        if tile.value == -1 then
            local collisionLayer = self.level:getLayer('Collision')
            local outsideX, outsideY = collisionLayer:convertGridToWorld(tile.row, tile.col)
            local newLevel = world:getLevelAt(outsideX, outsideY)
            return {
                type = CollisionType.OutsideLevel,
                level = newLevel,
            }
        end
    end

    return {
        type = CollisionType.None
    }
end

-- Performs updates in the X direction
function Player:updateX(updates, timeMultiplier)
    if self.xSpeed == 0 then
        print('No movement')
        return
    end

    local collisionLayer = self.level:getLayer('Collision')
    local xDistance = self.xSpeed * timeMultiplier
    local hitboxSize = self.fields.hitboxSize
    local hitboxMargin = (player.width - hitboxSize) / 2

    local tilesToCheck = self:getEdgeTiles('x', xDistance)

    local wallTiles = {}
    local exitTiles = {}

    for _, tile in ipairs(tilesToCheck) do
        if Tiles.isImpassable(tile) then
            table.insert(wallTiles, tile)
        elseif tile.value == -1 then
            -- Check if this leads to a level or not
            local outsideX, outsideY = collisionLayer:convertGridToWorld(tile.row, tile.col)
            local newLevel = world:getLevelAt(outsideX, outsideY)
            if newLevel then
                table.insert(exitTiles, {
                    tile = tile,
                    level = newLevel
                })
            else
                table.insert(wallTiles, tile)
            end
        end
    end

    -- Update our position to the furthest x position we can
    local newX
    if #wallTiles == 0 then
        newX = self.x + xDistance
    else
        -- We hit something
        -- Get the left and right most x
        local leftMostX = wallTiles[1].x
        local rightMostX = wallTiles[1].x + wallTiles[1].width
        for _, tile in ipairs(wallTiles) do
            if tile.x < leftMostX then
                leftMostX = tile.x
            end
            if tile.x + tile.width > rightMostX then
                rightMostX = tile.x + tile.width
            end
        end

        if xDistance > 0 then
            newX = leftMostX - hitboxSize - hitboxMargin
        elseif xDistance < 0 then
            newX = rightMostX - hitboxMargin
        end
    end

    self.x = newX

    -- Change levels if appropriate
    if #exitTiles > 0 then
        -- Just pick one for now unless we get bugs
        self:changeLevel(exitTiles[1].level)
    end
end

function Player:setXSpeed(newSpeed)
    local maxXSpeed = self.fields.maxXSpeed
    self.xSpeed = math.mid(-maxXSpeed, newSpeed, maxXSpeed)
end

function Player:changeXSpeed(impulse)
    local maxXSpeed = self.fields.maxXSpeed
    self.xSpeed = math.mid(-maxXSpeed, self.xSpeed + impulse, maxXSpeed)
end

function Player:setYSpeed(newSpeed)
    local maxYSpeed = self.fields.maxXSpeed
    self.ySpeed = math.mid(-maxYSpeed, newSpeed, maxYSpeed)
end

function Player:changeYSpeed(impulse)
    local maxYSpeed = self.fields.maxYSpeed
    self.ySpeed = math.mid(-maxYSpeed, self.ySpeed + impulse, maxYSpeed)
end

-- Updates the player's y coordinate based on the current speed
function Player:updateY(updates, timeMultiplier)
    local yDistance = self.ySpeed * timeMultiplier

    local result = self:checkForCollisions('y', yDistance)

    if result.type == CollisionType.OutsideLevel then
        if result.level then
            self:changeLevel(result.level)
            self.y = self.y + yDistance
        else
            self.jump:endJumping()
        end
    elseif result.type == CollisionType.None then
        self.y = self.y + yDistance
    elseif result.type == CollisionType.Wall then
        self.jump:endJumping()
    end
end

function Player:update(updates)
    local dt = love.timer.getDelta()
    local targetFPS = 60
    local fixItFactor = 1.5 -- Arbitrary factor that makes everything feel better
    local timeMultiplier = dt * targetFPS * fixItFactor

    for _, component in ipairs(self.components) do
        component:update(updates, timeMultiplier)
    end

    self:updateX(updates, timeMultiplier)
    self:updateY(updates, timeMultiplier)
end

-- Used to trigger a level change
function Player:changeLevel(newLevel)
    assert(newLevel ~= nil, 'Cannot change to an empty level')

    local oldLevel = self.level

    for _, component in pairs(self.components) do
        component:changeLevel(oldLevel, newLevel)
    end

    self:unbindFromLevel()
    self:bindToLevel(newLevel)

    world:setActiveLevel(newLevel.id)

    -- Reposition inside the new level
    self.x = math.mid(newLevel.x, self.x, newLevel.x + newLevel.width - self.width)
    self.y = math.mid(newLevel.y, self.y, newLevel.y + newLevel.height - self.height)

    -- Cancel momentum
    -- self.xSpeed = 0
end

-- Draws the player
function Player:draw()
    for _, component in ipairs(self.components) do
        component:draw()
    end
end

return Player
