local class = require('lib/middleclass')
local Entity = require('game/entities/Entity')

local Player = class('Player', Entity)

local Tiles = require('game/Tiles')

local StaminaComponent = require('game/entities/player/StaminaComponent')
local AnimationComponent = require('game/entities/player/AnimationComponent')
local RespawnComponent = require('game/entities/player/RespawnComponent')
local UseableComponent = require('game/entities/player/UseableComponent')
local CarryComponent = require('game/entities/player/CarryComponent')

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

    self.isClimbing = false
    self.isJumping = false
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
    local hitboxMargin = 0 - (self.fields.hitboxMargin or -2)

    local collisionLayer = self.level:getLayer('Collision')

    local upperLeftRow, upperLeftCol = collisionLayer:convertWorldToGrid(x + hitboxMargin, y + hitboxMargin)
    local lowerRightRow, lowerRightCol = collisionLayer:convertWorldToGrid(x + self.width - hitboxMargin,
        y + self.height - hitboxMargin)

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
    local accel = self.fields.accel
    local friction = self.fields.friction

    -- Update the player's horizontal velocity
    local impulse = 0
    if updates.moveLeft then
        if self.xSpeed > 0 then
            impulse = -friction
        else
            impulse = -accel
        end
        self.flipImage = true
    elseif updates.moveRight then
        if self.xSpeed < 0 then
            impulse = friction
        else
            impulse = accel
        end
        self.flipImage = false
    else
        local frictionEffect = friction
        local xDistance = self.xSpeed * timeMultiplier
        if math.abs(xDistance) < friction then
            frictionEffect = math.abs(xDistance)
        end
        impulse = -1 * math.sign(self.xSpeed) * frictionEffect
    end

    local maxXSpeed = self.fields.maxXSpeed
    self.xSpeed = math.mid(-maxXSpeed, self.xSpeed + impulse, maxXSpeed)
    local xDistance = self.xSpeed * timeMultiplier

    local result = self:checkForCollisions('x', xDistance)
    if result.type == CollisionType.OutsideLevel then
        if result.level and result.level ~= self.level then
            self:changeLevel(result.level)
            self.x = self.x + xDistance
        end
    elseif result.type == CollisionType.None then
        self.x = self.x + xDistance
    end
end

-- Update vertical component
function Player:updateY(updates, timeMultiplier)
    local jumpAccel = self.fields.jumpAccel
    local gravity = self.fields.gravity
    local initialGravityMultiplier = self.fields.initialGravityMultiplier
    local gravityDecay = self.fields.gravityDecay
    local climbSpeed = self.fields.climbSpeed
    local startGravity = gravity * initialGravityMultiplier

    local collisionLayer = self.level:getLayer('Collision')
    local jumpHeight = self.fields.jumpHeight * collisionLayer.tileSize

    local impulse = 0

    local climbableTile = self:getNearestClimbable()
    local currentGroundTiles = self:getGroundTiles(self.x, self.y)

    if updates.moveUp and climbableTile then
        -- Start Climbing up a climbable
        self.x = climbableTile.x + collisionLayer.tileSize / 2 - self.width / 2
        self.xSpeed = 0
        self.ySpeed = -climbSpeed
        self.isJumping = false
        self.isClimbing = true
    elseif updates.moveDown and climbableTile then
        -- Start climbing down a climbable
        self.x = climbableTile.x + collisionLayer.tileSize / 2 - self.width / 2
        self.xSpeed = 0
        self.ySpeed = climbSpeed
        self.isJumping = false
        self.isClimbing = true
    elseif self.isClimbing and not self.isJumping and climbableTile then
        -- Stopping while on a climbable
        self.ySpeed = 0
    elseif not self.isJumping and updates.jump and (#currentGroundTiles > 0 or self.isClimbing) then
        -- Start jumping
        self.isClimbing = false
        self.isJumping = true
        self.currentGravity = startGravity
        impulse = -jumpAccel
        self.jumpStart = self.y
    elseif updates.jump and self.isJumping and self.jumpStart - self.y < jumpHeight then
        -- Continue jumping upwards
        impulse = -jumpAccel
    else
        -- Let gravity bring us down!
        self.isClimbing = false
        self.isJumping = false
        if self.currentGravity < gravity then
            self.currentGravity = self.currentGravity + gravity * gravityDecay * timeMultiplier
        end
        impulse = self.currentGravity
    end

    local maxYSpeed = self.fields.maxYSpeed
    self.ySpeed = math.mid(-maxYSpeed, self.ySpeed + impulse, maxYSpeed)

    local yDistance = self.ySpeed * timeMultiplier

    local result = self:checkForCollisions('y', yDistance)

    if result.type == CollisionType.OutsideLevel then
        if result.level then
            self:changeLevel(result.level)
            self.y = self.y + yDistance
        else
            self.isJumping = false
        end
    elseif result.type == CollisionType.None then
        self.y = self.y + yDistance
    elseif result.type == CollisionType.Wall then
        self.isJumping = false
    end
end

function Player:update(updates)
    local dt = love.timer.getDelta()
    local targetFPS = 60
    local fixItFactor = 1.5
    local timeMultiplier = dt * targetFPS * fixItFactor

    self:updateX(updates, timeMultiplier)
    self:updateY(updates, timeMultiplier)

    for _, component in ipairs(self.components) do
        component:update(updates)
    end
end

-- Returns the nearest climbable tile in range
function Player:getNearestClimbable()
    local hitboxMargin = 0 - (self.fields.hitboxMargin or -2)
    local collisionLayer = self.level:getLayer('Collision')

    local upperLeftRow, upperLeftCol = collisionLayer:convertWorldToGrid(self.x + hitboxMargin, self.y + hitboxMargin)
    local lowerRightRow, lowerRightCol = collisionLayer:convertWorldToGrid(self.x + self.width - hitboxMargin,
        self.y + self.height - hitboxMargin)
    local results = collisionLayer:getTilesInRange(upperLeftRow, upperLeftCol, lowerRightRow + 1, lowerRightCol)

    local centerRow, centerCol = collisionLayer:convertWorldToGrid(self.x + self.width / 2, self.y + self.height / 2)

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

-- Used to trigger a level change
function Player:changeLevel(newLevel)
    assert(newLevel ~= nil, 'Cannot change to an empty level')

    local oldLevel = self.level
    local entityLayer = oldLevel:getLayer('Entities')
    entityLayer:unbindEntity(self)

    for _, component in pairs(self.components) do
        component:changeLevel(oldLevel, newLevel)
    end

    -- connect to the new level
    self.level = newLevel
    entityLayer = newLevel:getLayer('Entities')
    entityLayer:bindEntity(self)

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
