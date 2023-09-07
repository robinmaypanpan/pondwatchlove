local class = require('lib/middleclass')

local Player = class('Player')

local Tiles = require('game/Tiles')

local CollisionType = {
    None = 0,
    Wall = 1,
    OutsideLevel = 2
}

function Player:initialize(data, level)
    self.level = level
    self.data = data
    self.fields = {}

    for _, field in pairs(data.fieldInstances) do
        self.fields[field.__identifier] = field.__value
    end

    self.id = data.__identifier
    self.x = data.__worldX
    self.y = data.__worldY
    self.jumpStart = self.y

    self.xSpeed = 0
    self.ySpeed = 0

    self.isClimbing = false
    self.isJumping = false
    self.flipImage = false

    self.image = love.graphics.newImage('assets/sprites/birb.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.spritesheet = love.graphics.newImage('assets/sprites/birb_spritesheet.png')
    self.walkQuads = self:getSpritesheetQuads(self.spritesheet, 6, self.width, self.height)

    self.currentGravity = 0
    self.animProgress = 1
    self.animFrame = 1
end

-- takes an image, and using the other variables, creates a table of x,y coords to use
-- for quads in the for loop.
-- currently, this code only works for a 6 cell, horizintal animation
function Player:getSpritesheetQuads(image, frameCount, frameWidth, frameHeight)
    local quadData = {}
    local sheetWidth = image:getWidth()
    local sheetHeight = image:getHeight()
    for i = 0, frameCount, 1 do
        quadData[i + 1] = love.graphics.newQuad(frameWidth * i, 0, frameWidth, frameHeight, sheetWidth, sheetHeight)
    end
    return quadData
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
        print('tile: ' .. tile.id)
        local tileAbove = collisionLayer:getTile(tile.row - 1, tile.col)
        if Tiles.isImpassable(tileAbove) or Tiles.isEmpty(tile) then
        else
            table.insert(finalResults, tile)
        end
    end

    print('Remaining tiles ' .. #finalResults)

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
    local dt = love.timer.getDelta()

    local accel = self.fields.accel
    local friction = self.fields.friction
    local animSpeed = 12

    -- Update the player's horizontal velocity
    local impulse = 0
    if updates.moveLeft then
        if self.xSpeed > 0 then
            impulse = -friction
        else
            impulse = -accel
        end
        if self.animProgress >= 7 then
            self.animProgress = 1
        end
        self.animFrame = math.floor(self.animProgress)
        self.animProgress = self.animProgress + dt * animSpeed
        self.flipImage = true
    elseif updates.moveRight then
        if self.xSpeed < 0 then
            impulse = friction
        else
            impulse = accel
        end
        if self.animProgress >= 7 then -- this is to account for the fact that the animation is only 6 frames, not the right way to do this, but I just wanted to make it work for now
            self.animProgress = 1
        end
        self.animFrame = math.floor(self.animProgress)
        self.animProgress = self.animProgress + dt * animSpeed
        self.flipImage = false
    else
        local frictionEffect = friction
        local xDistance = self.xSpeed * timeMultiplier
        if math.abs(xDistance) < friction then
            frictionEffect = math.abs(xDistance)
        end
        self.animProgress = 1
        self.animFrame = 1
        impulse = -1 * math.sign(self.xSpeed) * frictionEffect
    end

    local maxXSpeed = self.fields.maxXSpeed
    self.xSpeed = math.mid(-maxXSpeed, self.xSpeed + impulse, maxXSpeed)
    local xDistance = self.xSpeed * timeMultiplier

    local result = self:checkForCollisions('x', xDistance)
    if result.type == CollisionType.OutsideLevel then
        if result.level and result.level ~= self.level then
            self:changeLevels(result.level)
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
            self:changeLevels(result.level)
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
function Player:changeLevels(newLevel)
    assert(newLevel ~= nil, 'Cannot change to an empty level')

    local oldLevel = self.level
    local entityLayer = oldLevel:getLayer('Entities')
    entityLayer:unbindEntity(self)

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

function Player:draw()
    local scale = 1
    local width = 0
    if self.flipImage then
        scale = -1
        width = self.width
    end

    love.graphics.draw(self.spritesheet, self.walkQuads[self.animFrame], self.x, self.y, 0, scale, 1, width)
end

return Player
