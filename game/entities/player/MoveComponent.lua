local class = require('lib/middleclass')
local PlayerComponent = require('game/entities/player/PlayerComponent')

local MoveComponent = class('MoveComponent', PlayerComponent)

function MoveComponent:initialize(player)
    PlayerComponent.initialize(self, player)
end

function MoveComponent:update(updates, timeMultiplier)
    local player = self.player
    local accel = player.fields.accel
    local friction = player.fields.friction

    -- Update the player's horizontal velocity
    local impulse = 0
    if updates.moveLeft then
        if player.xSpeed > 0 then
            impulse = -friction
        else
            impulse = -accel
        end
        player.flipImage = true
    elseif updates.moveRight then
        if player.xSpeed < 0 then
            impulse = friction
        else
            impulse = accel
        end
        player.flipImage = false
    else
        local frictionEffect = friction
        local xDistance = player.xSpeed * timeMultiplier
        if math.abs(xDistance) < friction then
            frictionEffect = math.abs(xDistance)
        end
        impulse = -1 * math.sign(player.xSpeed) * frictionEffect
    end

    player:changeXSpeed(impulse)
end

return MoveComponent
