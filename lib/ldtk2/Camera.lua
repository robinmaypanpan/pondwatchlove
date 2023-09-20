local class = require('middleclass')

local flux = require('flux')

local Camera = class('Camera')

function Camera:initialize(world, settings)
    self.world = world

    if settings == nil then
        settings = {
            maxSpeed = 200
        }
    end

    self.settings = settings

    self.x = 0
    self.y = 0
    self.targetX = 0
    self.targetY = 0

    self.speed = 0
    self.tween = nil

    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    print('Screen size is ' .. self.width .. 'x' .. self.height)
end

-- Sets the new position of the camera
function Camera:setTarget(x, y)
    print('set target to ' .. x .. ', ' .. y)
    if self.settings.centerTarget then
        x = x - self.width / 2
        y = y - self.height / 2
        print('Centering target to ' .. x .. ', ' .. y)
    end

    self.targetX = x
    self.targetY = y
end

-- Moves the camera by the indicated position
function Camera:move(dx, dy)
    self.targetX = self.targetX + dx
    self.targetY = self.targetY + dy
end

-- Converts screen coordinates to world coordinates
function Camera:screenToWorld(screenX, screenY)
    print('screenToWorld ' .. screenX .. ', ' .. screenY)
    local x = screenX + self.x
    local y = screenY + self.y
    print('returning ' .. x .. ', ' .. y)
    return x, y
end

function Camera:worldToScreen(worldX, worldY)

end

function Camera:setZoom(scale)
end

function Camera:update(dt)
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    if math.abs(dx) > 1 or math.abs(dy) > 1 then
        if self.settings.movement == 'dampen' then
            local dampValue = self.settings.dampValue or 3
            self.x = self.x + dx * math.min(dampValue * dt, 1)
            self.y = self.y + dy * math.min(dampValue * dt, 1)
        elseif self.settings.movement == 'linear' then
            -- TODO: Implement this!
        else
            self.x = math.floor(self.targetX)
            self.y = math.floor(self.targetY)
        end
    else
        self.x = math.floor(self.targetX)
        self.y = math.floor(self.targetY)
    end
end

-- Executes the graphics translation
function Camera:attach()
    love.graphics.push() -- stores the default coordinate system

    love.graphics.origin()
    love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

-- Removes the camera
function Camera:detach()
    love.graphics.pop()
end

return Camera
