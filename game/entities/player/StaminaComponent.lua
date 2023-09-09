local class = require('lib/middleclass')

local StaminaComponent = class('StaminaComponent')

function StaminaComponent:initialize(player)
    self.player = player
    self.stamina = 100
    self.maxStamina = 100
    self.font = love.graphics.newFont(60)
end

-- Resets stamina to maximum
function StaminaComponent:reset()
    self.stamina = 100
end

-- Boosts the stamina by the indicated amount
function StaminaComponent:boost(amount)
    self.stamina = self.stamina + amount
    self.stamina = math.min(self.stamina, 100)
end

--Reduces the stamina by the amount specified by the level
function StaminaComponent:changeLevel(oldLevel, newLevel)
    if oldLevel and oldLevel.fields.staminaCost then
        self.stamina = self.stamina - oldLevel.fields.staminaCost
    else
        self.stamina = self.stamina - 10
    end
    self.stamina = math.max(0, self.stamina)
end

function StaminaComponent:update(updates)
    uiCanvas:renderTo(function()
        love.graphics.setFont(self.font)
        love.graphics.print('' .. self.stamina, 50, 50)
    end)
end

function StaminaComponent:draw()
end

return StaminaComponent
