local class = require('lib/middleclass')

local Player = class('Player')

local MoveSpeed = 2

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

    self.currentGravity = 0
end

-- Check for collisions in all the right places
function Player:checkForCollisions(direction, distance)
    local collisionLayer = self.level:getLayer('Collision')

    local newX = self.x
    local newY = self.y

    if direction == 'x' then
        newX = newX + distance
    elseif direction == 'y' then
        newY = newY + distance
    end

    local upperRightRow, upperRightCol = collisionLayer:convertWorldToGrid(newX + self.width, newY)
    local lowerRightRow, lowerRightCol = collisionLayer:convertWorldToGrid(newX + self.width, newY + self.height)
    local upperLeftRow, upperLeftCol = collisionLayer:convertWorldToGrid(newX, newY)
    local lowerLeftRow, lowerLeftCol = collisionLayer:convertWorldToGrid(newX, newY + self.height)

    local results = {}
    if direction == 'x' and distance > 0 then
        results = collisionLayer:getTilesInRange(upperRightRow, upperRightCol, lowerRightRow, lowerRightCol)
    elseif direction == 'x' and distance < 0 then
        results = collisionLayer:getTilesInRange(upperLeftRow, upperLeftCol, lowerLeftRow, lowerLeftCol)
    elseif direction == 'y' and distance > 0 then
        results = collisionLayer:getTilesInRange(lowerLeftRow, lowerLeftCol, lowerRightRow, lowerRightCol)
    elseif direction == 'y' and distance < 0 then
        results = collisionLayer:getTilesInRange(upperLeftRow, upperLeftCol, upperRightRow, upperRightCol)
    else
        return {
            type = CollisionType.None
        }
    end

    assert(#results > 0, 'No tiles found to collide with')

    for _, tile in ipairs(results) do
        if tile.value == 1 or tile.value == 2 then
            return {
                type = CollisionType.Wall
            }
        end
    end

    for _, tile in ipairs(results) do
        if tile.value == -1 then
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

function Player:update(updates)
    local maxXSpeed = self.fields.maxXSpeed
    local accel = self.fields.accel
    local friction = self.fields.friction
    local maxYSpeed = self.fields.maxYSpeed
    local jumpAccel = self.fields.jumpAccel
    local gravity = self.fields.gravity
    local initialGravityMultiplier = self.fields.initialGravityMultiplier
    local gravityDecay = self.fields.gravityDecay
    local climbSpeed = self.fields.climbSpeed
    local startGravity = gravity * initialGravityMultiplier

    local collisionLayer = self.level:getLayer('Collision')
    local jumpHeight = self.fields.jumpHeight * collisionLayer.tileSize

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
        if math.abs(self.xSpeed) < friction then
            frictionEffect = math.abs(self.xSpeed)
        end
        impulse = -1 * math.sign(self.xSpeed) * frictionEffect
    end

    self.xSpeed = math.mid(-maxXSpeed, self.xSpeed + impulse, maxXSpeed)

    local result = self:checkForCollisions('x', self.xSpeed)
    if result.type == CollisionType.OutsideLevel then
        if result.level and result.level ~= self.level then
            self:changeLevels(result.level)
            self.x = self.x + self.xSpeed
        end
    elseif result.type == CollisionType.None then
        self.x = self.x + self.xSpeed
    end

    -- Now do the vertical component
    impulse = 0

    if updates.moveUp and self:isOnClimbable() then
        -- Start Climbing up a climbable
        self.xSpeed = 0
        self.ySpeed = -climbSpeed
        self.isJumping = false
        self.isClimbing = true
    elseif updates.moveDown and self:isOnClimbable() then
        -- Start climbing down a climbable
        self.xSpeed = 0
        self.ySpeed = climbSpeed
        self.isJumping = false
        self.isClimbing = true
    elseif self.isClimbing and not self.isJumping and self:isOnClimbable() and not self:isOnGround() then
        -- Stopping while on a climbable
        self.ySpeed = 0
    elseif updates.jump and (self:isOnGround() or self.isClimbing) then
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
            self.currentGravity = self.currentGravity + gravity * gravityDecay
        end
        impulse = self.currentGravity
    end

    self.ySpeed = math.mid(-maxYSpeed, self.ySpeed + impulse, maxYSpeed)

    local result = self:checkForCollisions('y', self.ySpeed)
    if result.type == CollisionType.OutsideLevel then
        if result.level then
            self:changeLevels(result.level)
            self.y = self.y + self.ySpeed
        else
            self.isJumping = false
        end
    elseif result.type == CollisionType.None then
        self.y = self.y + self.ySpeed
    else
        self.isJumping = false
    end
end

-- Returns true if the player is on a Climbable object
function Player:isOnClimbable()
    local collisionLayer = self.level:getLayer('Collision')
    local upperLeftRow, upperLeftCol = collisionLayer:convertWorldToGrid(self.x, self.y)
    local lowerRightRow, lowerRightCol = collisionLayer:convertWorldToGrid(self.x + self.width,
        self.y + self.height + collisionLayer.tileSize / 2)
    local results = collisionLayer:getTilesInRange(upperLeftRow, upperLeftCol, lowerRightRow, lowerRightCol)

    for _, tile in ipairs(results) do
        if tile.value == 4 then
            return true
        end
    end

    return false
end

-- Returns true if the player is on the ground
function Player:isOnGround()
    local collisionLayer = self.level:getLayer('Collision')

    local lowerRightRow, lowerRightCol = collisionLayer:convertWorldToGrid(self.x + self.width,
        self.y + self.height + collisionLayer.tileSize / 2)
    local lowerLeftRow, lowerLeftCol = collisionLayer:convertWorldToGrid(self.x,
        self.y + self.height + collisionLayer.tileSize / 2)

    local results = collisionLayer:getTilesInRange(lowerLeftRow, lowerLeftCol, lowerRightRow, lowerRightCol)

    assert(#results > 0, "No tiles found to detect ground")

    for _, tile in ipairs(results) do
        if tile.value == 1 or tile.value == 2 then
            return true
        end
    end

    return false
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
    love.graphics.draw(self.image, self.x, self.y, 0, scale, 1, width)
end

return Player
