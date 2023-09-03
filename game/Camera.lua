local class = require('lib/middleclass')

local Camera = class('Camera')
local flux = require('lib/flux')

function Camera:initialize(player, world)
    self.player = player
    self.world = world
    self.x = 0
    self.y = 0
    self.lastLevel = player.level
    self.isTransitioning = false
end

-- Returns the camera position that should be applied in the current
function Camera:getCameraInLevel(level)
    local screenWidth = self.world.levelWidth
    local screenHeight = self.world.levelHeight

    -- Center the viewport on the player
    local centerX = self.player.x - screenWidth / 2
    local centerY = self.player.y - screenHeight / 2

    -- Prevent the camera from exiting the level
    local maxCameraX = level.x + level.width - screenWidth
    local maxCameraY = level.y + level.height - screenHeight

    -- Set the camera position to within the bounds of the level, but centered on our character
    local cameraX = math.mid(level.x, centerX, maxCameraX)
    local cameraY = math.mid(level.y, centerY, maxCameraY)

    return cameraX, cameraY
end

-- Shift the camera to a location that is ideal
function Camera:update()
    if self.isTransitioning then
        -- No updates needed if we are in a level transition
        return
    end

    if self.lastLevel ~= self.player.level then
        -- We changed levels
        self.isTransitioning = true
        local destinationX, destinationY = self:getCameraInLevel(self.player.level)
        flux.to(self, 0.6, { x = destinationX, y = destinationY }):ease("quartinout"):oncomplete(
            function()
                self.lastLevel = self.player.level
                self.isTransitioning = false
            end
        )
    else
        self.lastLevel = self.player.level
        self.x, self.y = self:getCameraInLevel(self.player.level)
    end
end

-- Updates the camera position to the latest x and y
function Camera:draw()
    love.graphics.translate(-self.x, -self.y)
end

return Camera
