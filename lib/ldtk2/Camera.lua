local class = require('middleclass')

local flux = require('flux')

local Camera = class('Camera')

-- Settings options
-- movement = dampen
--            linear
--            instant
-- centerTarget
-- dampValue
-- levelZoom
-- zoom

function Camera:initialize(world, settings)
    self.world = world

    if settings == nil then
        settings = {
            maxSpeed = 200,
            tweenSpeed = 0.5,
            tweenEase = 'quadinout'
        }
    end

    self.settings = settings

    self.x = 0
    self.y = 0
    self.targetX = 0
    self.targetY = 0

    self.speed = 0
    self.tween = nil

    local zoom = 1
    if settings.levelZoom ~= nil and world.gridWidth ~= nil then
        -- Set the zoom to a multiple of the width of the level grid
        zoom = (love.graphics.getWidth() / world.gridWidth) / settings.levelZoom
    elseif settings.zoom ~= nil then
        zoom = settings.zoom
    end

    self:setZoom(zoom)
end

-- Instead of following a target, allows direct control over camera position
function Camera:moveTo(x, y)
    return flux.to(self, self.settings.tweenSpeed, { x = x, y = y, targetX = x, targetY = y }):ease(self.settings
        .tweenEase)
end

-- Sets the new position of the camera
function Camera:setTarget(x, y)
    if self.settings.centerTarget then
        x = x - self.width / 2
        y = y - self.height / 2
    end

    self.targetX = x
    self.targetY = y
end

-- Moves the camera by the indicated position
function Camera:move(dx, dy)
    self.targetX = self.targetX + dx
    self.targetY = self.targetY + dy
end

-- Converts a delta in screen space to a world delta
function Camera:screenDeltaToWorld(screenDX, screenDY)
    return screenDX / self.zoom, screenDY / self.zoom
end

-- Converts screen coordinates to world coordinates
function Camera:screenToWorld(screenX, screenY)
    local x = screenX / self.zoom + self.x
    local y = screenY / self.zoom + self.y
    return x, y
end

function Camera:worldToScreen(worldX, worldY)
    local x = (worldX - self.x) * self.zoom
    local y = (worldY - self.y) * self.zoom
    return x, y
end

-- Sets the camera zoom level
function Camera:setZoom(zoom)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    if self.zoom ~= nil then
        -- Reposition to keep the original zoom centered
        -- TODO: Change this to consider centerTarget
        local zx = (screenWidth / self.zoom - screenWidth / zoom) / 2
        local zy = (screenHeight / self.zoom - screenHeight / zoom) / 2

        self.x = self.x + zx
        self.y = self.y + zy

        self.targetX = self.targetX + zx
        self.targetY = self.targetY + zy
    end

    self.zoom = zoom
    self.width = screenWidth / zoom
    self.height = screenHeight / zoom
end

-- Locks the camera to the provided rectangle in world space
function Camera:lockCamera(rectangle)
    self.cameraLock = rectangle
end

-- Unlocks the camera to allow it to show any position
function Camera:unlockCamera()
    self.cameraLock = nil
end

function Camera:update(dt)
    if self.cameraLock then
        local lockLeft = self.cameraLock.x
        local lockRight = self.cameraLock.x + self.cameraLock.width - self.width
        local lockTop = self.cameraLock.y
        local lockBottom = self.cameraLock.y + self.cameraLock.height - self.height
        self.targetX = math.mid(lockLeft, self.targetX, lockRight)
        self.targetY = math.mid(lockTop, self.targetY, lockBottom)
    end

    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    if math.abs(dx) >= 1 or math.abs(dy) >= 1 then
        if self.settings.movement == 'dampen' then
            local dampValue = self.settings.dampValue or 3
            self.x = self.x + dx * math.min(dampValue * dt, 1)
            self.y = self.y + dy * math.min(dampValue * dt, 1)
        elseif self.settings.movement == 'linear' then
            -- TODO: Implement this!
        else
            self.x = self.targetX
            self.y = self.targetY
            self.targetX = self.x
            self.targetY = self.y
        end
    else
        self.x = self.targetX
        self.y = self.targetY
        self.targetX = self.x
        self.targetY = self.y
    end
end

-- Executes the graphics translation
function Camera:attach()
    love.graphics.push() -- stores the default coordinate system

    love.graphics.origin()
    love.graphics.scale(self.zoom)
    love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

-- Removes the camera
function Camera:detach()
    love.graphics.pop()
end

return Camera
