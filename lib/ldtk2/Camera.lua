local class = require('middleclass')

local Camera = class('Camera')

function Camera:initialize(world, settings)
    self.world = world
    self.settings = settings

    self.x = 0
    self.y = 0
    self.targetX = 0
    self.targetY = 0

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()
end

-- Sets the new position of the camera
function Camera:setTarget(x, y)
    if self.settings.centerTarget then
        x = x - self.width / 2
        y = y - self.height / 2
    end

    self.targetX = math.floor(x)
    self.targetY = math.floor(y)
end

-- Moves the camera by the indicated position
function Camera:move(dx, dy)
    self.targetX = math.floor(self.x + dx)
    self.targetY = math.floor(self.y + dy)
end

-- Converts screen coordinates to world coordinates
function Camera:screenToWorld(screenX, screenY)
    local x = screenX + self.x
    local y = screenY + self.y
    return x, y
end

function Camera:setZoom(scale)
end

function Camera:update(dt)
    self.x = self.targetX
    self.y = self.targetY
end

-- Executes the graphics translation
function Camera:translateGraphics()
    local x = self.x
    local y = self.y

    love.graphics.origin()
    love.graphics.translate(-self.x, -self.y)
end

return Camera
