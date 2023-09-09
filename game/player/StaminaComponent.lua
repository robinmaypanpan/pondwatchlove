local class = require('lib/middleclass')

local StaminaComponent = class('StaminaComponent')

function StaminaComponent:initialize(player)
    self.player = player
    self.stamina = 100
    self.font = love.graphics.newFont(60)
end

function StaminaComponent:update()
    uiCanvas:renderTo(function()
        love.graphics.setFont(self.font)
        love.graphics.print('' .. self.stamina, 50, 50)
    end)
end

function StaminaComponent:draw()
end

return StaminaComponent
