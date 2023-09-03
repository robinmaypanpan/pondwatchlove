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

-- Checks for collision at the indicated position
function Player:checkCollision(x, y)
    if not self.level:isWithinLevel(x, y) then
        return CollisionType.OutsideLevel
    end

    local collisionLayer = self.level:getLayer('Collision')
    local collideTile = collisionLayer:getTileInWorld(x, y)
    if collideTile.value == 1 or collideTile.value == 2 then
        return CollisionType.Wall
    else
        return CollisionType.None
    end
end

-- Check for collisions in all the right places
function Player:checkForCollisions(x, y)
    local results = {}

    table.insert(results, self:checkCollision(x, y))
    table.insert(results, self:checkCollision(x + self.width, y))
    table.insert(results, self:checkCollision(x, y + self.height))
    table.insert(results, self:checkCollision(x + self.width, y + self.height))

    for _, result in ipairs(results) do
        if result == CollisionType.Wall then
            return result
        end
    end

    for _, result in ipairs(results) do
        if result == CollisionType.OutsideLevel then
            return result
        end
    end

    return CollisionType.None
end

function Player:update(updates)
    local MaxXSpeed = 2
    local Accel = 0.1
    local Friction = 0.2
    local MaxYSpeed = 2
    local JumpAccel = 0.5
    local Gravity = 0.2

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

    local result = self:checkForCollisions(self.x + self.xSpeed, self.y)
    if result ~= CollisionType.Wall then
        self.x = self.x + self.xSpeed
    end
    if result == CollisionType.OutsideLevel then
        self:changeLevels()
        return
    end

    -- Now do the vertical component
    impulse = 0
    self.jump = updates.jump
    if updates.jump and self:isOnGround() then
        self.isJumping = true
        impulse = -JumpAccel
    elseif updates.jump and self.isJumping then
        impulse = -JumpAccel
    else
        self.isJumping = false
        impulse = Gravity
    end

    self.ySpeed = math.mid(-MaxYSpeed, self.ySpeed + impulse, MaxYSpeed)

    local result = self:checkForCollisions(self.x, self.y + self.ySpeed)
    if result ~= CollisionType.Wall then
        self.y = self.y + self.ySpeed
    elseif result == CollisionType.Wall then
        self.ySpeed = 0
    end
    if result == CollisionType.OutsideLevel then
        self:changeLevels()
        return
    end
end

-- Returns true if the player is on the ground
function Player:isOnGround()
    return true
end

-- Used to trigger a level change
function Player:changeLevels()
    local newLevel = world:getLevelAt(self.x, self.y)

    if newLevel == nil then
        -- do nothing
        return
    end

    local oldLevel = self.level
    local entityLayer = oldLevel:getLayer('Entities')
    entityLayer:unbindEntity(self)

    local newLevel = world:getLevelAt(self.x, self.y)
    self.level = newLevel
    entityLayer = newLevel:getLayer('Entities')
    entityLayer:bindEntity(self)

    world:setActiveLevel(newLevel.id)
end

function Player:draw()
    local scale = 1
    local width = 0
    if self.flipImage then
        scale = -1
        width = self.width
    end
    love.graphics.draw(self.image, self.x, self.y, 0, scale, 1, width)
    love.graphics.print('x Speed: ' .. self.xSpeed, self.x, self.y - 20)
    love.graphics.print('y Speed: ' .. self.ySpeed, self.x, self.y - 35)
    love.graphics.print('Jumping: ' .. string.fromBool(self.jump), self.x, self.y - 50)
end

return Player
