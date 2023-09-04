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

    self.xSpeed = 0
    self.ySpeed = 0

    self.isJumping = false
    self.flipImage = false

    self.image = love.graphics.newImage('assets/sprites/birb.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
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
    local MaxXSpeed = self.fields.MaxXSpeed
    local Accel = self.fields.Accel
    local Friction = self.fields.Friction
    local MaxYSpeed = self.fields.MaxYSpeed
    local JumpAccel = self.fields.JumpAccel
    local Gravity = self.fields.Gravity

    -- Update the player's horizontal velocity
    local impulse = 0
    if updates.moveLeft then
        if self.xSpeed > 0 then
            impulse = -Friction
        else
            impulse = -Accel
        end
        self.flipImage = true
    elseif updates.moveRight then
        if self.xSpeed < 0 then
            impulse = Friction
        else
            impulse = Accel
        end
        self.flipImage = false
    else
        local frictionEffect = Friction
        if math.abs(self.xSpeed) < Friction then
            frictionEffect = math.abs(self.xSpeed)
        end
        impulse = -1 * math.sign(self.xSpeed) * frictionEffect
    end

    self.xSpeed = math.mid(-MaxXSpeed, self.xSpeed + impulse, MaxXSpeed)

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
    local startGravity = Gravity * self.fields.InitialGravityMultiplier
    self.currentGravity = startGravity
    impulse = 0
    self.jump = updates.jump
    if updates.jump and self:isOnGround() then
        self.isJumping = true
        self.currentGravity = startGravity
        impulse = -JumpAccel
    elseif updates.jump and self.isJumping then
        self.currentGravity = startGravity
        impulse = -JumpAccel
    else
        self.isJumping = false
        if self.currentGravity < Gravity then
            self.currentGravity = self.currentGravity + Gravity * self.fields.GravityDecay
        end
        impulse = self.currentGravity
    end

    self.ySpeed = math.mid(-MaxYSpeed, self.ySpeed + impulse, MaxYSpeed)

    local result = self:checkForCollisions('y', self.ySpeed)
    if result.type == CollisionType.OutsideLevel then
        if result.level then
            self:changeLevels(result.level)
            self.y = self.y + self.ySpeed
        end
    elseif result.type == CollisionType.None then
        self.y = self.y + self.ySpeed
    end
end

-- Returns true if the player is on the ground
function Player:isOnGround()
    local collisionLayer = self.level:getLayer('Collision')

    return true
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
