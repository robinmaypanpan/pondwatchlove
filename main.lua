if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

require('lib/table')
require('lib/math')
require('lib/string')

local flux = require('lib/flux')
local LevelBuilder = require('lib/ldtk/LevelBuilder')
local Player = require('game/Player')

local player

local entityTable = {
    Player = function(data, level)
        player = Player:new(data, level)
        return player
    end
}

function love.load(arg)
    love.window.setTitle('Garden Love')
    love.window.setMode(1280, 720, {
        fullscreen = false
    })

    levelFilename = 'assets/levels/world.ldtk'
    if arg and #arg > 1 then
        levelFileName = arg[2]
    end

    local builder = LevelBuilder:new(entityTable)
    world = builder:load(levelFilename)

    world:setActiveLevel('Entrance')
end

-- Called before calling draw each time a frame updates
function love.update(dt)
    flux.update(dt)

    if player then
        local moveLeft = love.keyboard.isDown('a') or love.keyboard.isDown('left')
        local moveRight = love.keyboard.isDown('d') or love.keyboard.isDown('right')
        local moveUp = love.keyboard.isDown('w') or love.keyboard.isDown('up')

        local jump = love.keyboard.isDown('space')

        player:update({
            moveLeft = moveLeft,
            moveRight = moveRight,
            jump = jump or moveUp
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

local camera = { x = 0, y = 0 }
local isLevelTransition = false
local lastLevel

function getCameraInLevel(level)
    local screenWidth = world.levelWidth
    local screenHeight = world.levelHeight

    -- Center the viewport on the player
    local centerX = player.x - screenWidth / 2
    local centerY = player.y - screenHeight / 2

    -- Prevent the camera from exiting the level
    local maxCameraX = level.x + level.width - screenWidth
    local maxCameraY = level.y + level.height - screenHeight

    -- Set the camera position to within the bounds of the level, but centered on our character
    local cameraX = math.mid(level.x, centerX, maxCameraX)
    local cameraY = math.mid(level.y, centerY, maxCameraY)

    return cameraX, cameraY
end

-- Shift the camera to a location that is ideal
function updateCamera(player, world)
    if isLevelTransition then
        -- Nothin to do thanks to flux!
    elseif lastLevel ~= player.level then
        isLevelTransition = true
        destinationX, destinationY = getCameraInLevel(player.level)
        flux.to(camera, 0.6, { x = destinationX, y = destinationY }):ease("quartinout"):oncomplete(
            function()
                lastLevel = player.level
                isLevelTransition = false
            end
        )
    else
        lastLevel = player.level
        camera.x, camera.y = getCameraInLevel(player.level)
    end

    love.graphics.translate(-camera.x, -camera.y)
end
