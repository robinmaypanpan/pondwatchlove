local class = require('middleclass')

local Camera = class('Camera')

function Camera:initialize(settings)
    self.x = 0
    self.y = 0
    self.targetX = 0
    self.targetY = 0
end

-- Sets the new position of the camera
function Camera:setPosition(x,y)
    self.x = x
    self.y = y
end

function Camera:setZoom(scale)
end

function Camera:update(dt)
end

-- Executes the graphics translation
function Camera:translateGraphics()
    love.graphics.origin()
    love.graphics.translate(-self.camera.x, -self.camera.y)
end

return Camera