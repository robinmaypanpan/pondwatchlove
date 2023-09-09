local class = require('lib/middleclass')

local JumpComponent = class('JumpComponent')

local JumpAccel, Gravity, InitialGravityMultiplier, GravityDecay, ClimbSpeed, StartGravity

function JumpComponent:initialize(player)
    self.player = player

    self.jumpState = 'idle'

    self.jumpStart = player.y

    self.currentGravity = 0

    JumpAccel = player.fields.jumpAccel
    Gravity = player.fields.gravity
    InitialGravityMultiplier = player.fields.initialGravityMultiplier
    GravityDecay = player.fields.gravityDecay
    ClimbSpeed = player.fields.climbSpeed
    StartGravity = Gravity * InitialGravityMultiplier
end

-- Returns true if the player is in a situation where they can jump
function JumpComponent:canJump()
    local currentGroundTiles = self.player:getGroundTiles(self.player.x, self.player.y)

    return #currentGroundTiles > 0 and self.jumpState == 'idle'
end

-- Returns true if you can jump higher
function JumpComponent:canJumpHigher()
    local collisionLayer = self.level:getLayer('Collision')
    local jumpHeight = self.fields.jumpHeight * collisionLayer.tileSize

    return self.jumpState == 'rising' and self.jumpStart - self.player.y < jumpHeight
end

-- Returns true if the player is currently jumping
function JumpComponent:isJumping()
    return self.jumpState ~= 'idle'
end

-- Sets the player to the "landed" condition
function JumpComponent:endJumping()
    if self.jumpState == 'falling' then
        self.jumpState = 'idle'
    elseif self.jumpState == 'rising' then
        self.jumpState = 'falling'
        self.currentGravity = StartGravity
    end
end

function JumpComponent:update(updates, timeMultiplier)
    local canJumpHigher = self:canJumphigher()

    if self.jumpState == 'rising' and (not canJumpHigher or not updates.jump) then
        self.jumpState = 'falling'
        self.currentGravity = StartGravity
    elseif updates.jump and self:canJump() then
        self.jumpState = 'rising'
    end

    if self.jumpState == 'rising' then
        self.player:accelY(-JumpAccel, timeMultiplier)
    elseif self.jumpState == 'falling' then
        self.player:accelY(self.currentGravity, timeMultiplier)
    end
end

function JumpComponent:draw()
end

return JumpComponent
