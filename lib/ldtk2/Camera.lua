local class = require('middleclass')

local Camera = class('Camera')

function Camera:initialize(settings)
    self.x = 0
    self.y = 0
    self.targetX = 0
    self.targetY = 0
end

-- Sets the new position of the camera
function Camera:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Moves the camera by the indicated position
function Camera:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Camera:setZoom(scale)
end

function Camera:update(dt)
end

-- Executes the graphics translation
function Camera:translateGraphics()
    love.graphics.origin()
    love.graphics.translate(-self.x, -self.y)
end

return Camera
