local class = require('lib/middleclass')
local PlayerComponent = require('game/entities/player/PlayerComponent')

local JumpComponent = class('JumpComponent', PlayerComponent)

local JumpAccel, Gravity, InitialGravityMultiplier, GravityDecay, ClimbSpeed, StartGravity

function JumpComponent:initialize(player)
    PlayerComponent.initialize(self, player)

    self.jumpState = 'idle'

    self.jumpStart = player.y

    self.currentGravity = 0

    JumpAccel = player.fields.jumpAccel
    Gravity = player.fields.gravity
    InitialGravityMultiplier = player.fields.initialGravityMultiplier
    GravityDecay = player.fields.gravityDecay
    StartGravity = Gravity * InitialGravityMultiplier
end

-- Returns true if the player is in a situation where they can jump
function JumpComponent:canJump()
    return self:isOnGround() and self.jumpState == 'idle'
end

-- Returns true if you can jump higher
function JumpComponent:canJumpHigher()
    local player = self.player
    local collisionLayer = player.level:getLayer('Collision')
    local jumpHeight = player.fields.jumpHeight * collisionLayer.tileSize

    return self.jumpState == 'rising' and self.jumpStart - player.y < jumpHeight
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

-- Returns true if the player is on the ground
function JumpComponent:isOnGround()
    local hitbox = self.player:getHitbox(self.player.x, self.player.y)

    local currentGroundTiles = self.player:getGroundTiles(self.player.x, self.player.y)

    if #currentGroundTiles == 0 then
        return false
    end

    local justAboveGround = true
    local alignedWithGround = false
    for _, groundTile in ipairs(currentGroundTiles) do
        local isJustAboveGround = math.abs(groundTile.y - hitbox.bottom) < 2
        local hitboxAlignedWithTile = groundTile.x <= hitbox.right and groundTile.x + groundTile.width >= hitbox.left
        if hitboxAlignedWithTile then
            alignedWithGround = true
            justAboveGround = justAboveGround and isJustAboveGround
        end
    end

    return justAboveGround and alignedWithGround
end

function JumpComponent:update(updates, timeMultiplier)
    local canJumpHigher = self:canJumpHigher()
    local currentGroundTiles = self.player:getGroundTiles(self.player.x, self.player.y)

    local newJumpState = self.jumpState

    if self.jumpState == 'idle' then
        if not self:isOnGround() then
            newJumpState = 'falling'
            self.currentGravity = StartGravity
        elseif updates.jump and self:canJump() then
            newJumpState = 'rising'
            self.jumpStart = player.y
        end
    elseif self.jumpState == 'rising' then
        if updates.jump and canJumpHigher then
            self.currentGravity = StartGravity
        else
            newJumpState = 'falling'
        end
    elseif self.jumpState == 'falling' then
        if #currentGroundTiles > 0 then
            newJumpState = 'idle'
        end
    end

    self.jumpState = newJumpState

    if self.jumpState == 'rising' then
        self.player:changeYSpeed(-JumpAccel, timeMultiplier)
    elseif self.jumpState == 'falling' then
        if self.currentGravity < Gravity then
            self.currentGravity = self.currentGravity + Gravity * GravityDecay * timeMultiplier
        end
        self.player:changeYSpeed(self.currentGravity, timeMultiplier)
    end
end

return JumpComponent
