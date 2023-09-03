if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

require('lib/table')
require('lib/math')

local LevelBuilder = require('lib/ldtk/LevelBuilder')
local Player = require('game/Player')

local player
local world

local entityTable = {
    Player = function(data, level)
        player = Player:new(data, level)
        return player
    end
}

function love.load(arg)
    love.window.setTitle('Garden Love')
    love.window.setMode(1920, 1080, {
        fullscreen = false
    })

    levelFilename = 'assets/levels/world.ldtk'
    if arg and #arg > 1 then
        levelFileName = arg[2]
    end

    local builder = LevelBuilder:new(entityTable)
    world = builder:load(levelFilename)

    world:activateLevel('Entrance')
end

-- Called before calling draw each time a frame updates
function love.update(dt)
    if player then
        local moveLeft = love.keyboard.isDown('a') or love.keyboard.isDown('left')
        local moveRight = love.keyboard.isDown('d') or love.keyboard.isDown('right')
        local moveUp = love.keyboard.isDown('w') or love.keyboard.isDown('up')
        local moveDown = love.keyboard.isDown('s') or love.keyboard.isDown('down')

        local jump = love.keyboard.isDown('space')

        player:update({
            moveLeft = moveLeft,
            moveRight = moveRight,
            moveUp = moveUp,
            moveDown = moveDown,
            jump = jump
        })
    end
end

-- Called after calling update each frame.
function love.draw()
    local scale = love.graphics.getWidth() / world.levelWidth
    love.graphics.scale(scale)

    updateCamera(player, world)

    world:draw()
end

-- Shift the camera to a location that is ideal
function updateCamera(player, world)
    local screenWidth = world.levelWidth
    local screenHeight = world.levelHeight

    -- Center the viewport on the player
    local centerX = player.x - screenWidth / 2
    local centerY = player.y - screenHeight / 2

    -- Prevent the camera from exiting the level
    local maxCameraX = player.level.x + player.level.width - screenWidth
    local maxCameraY = player.level.y + player.level.height - screenHeight

    -- Set the camera position to within the bounds of the level, but centered on our character
    local cameraX = math.mid(player.level.x, centerX, maxCameraX)
    local cameraY = math.mid(player.level.y, centerY, maxCameraY)

    love.graphics.translate(-cameraX, -cameraY)
end
