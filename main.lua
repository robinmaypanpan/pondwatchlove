if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

require('lib/table')
require('lib/math')
require('lib/string')

local flux = require('lib/flux')

local LevelBuilder = require('lib/ldtk/LevelBuilder')
local Player = require('game/Player')
local Camera = require('game/Camera')

local player
local camera

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

    camera = Camera:new(player, world)
end

local isLevelTransition = false

-- Called before calling draw each time a frame updates
function love.update(dt)
    flux.update(dt)

    if player and not camera.isTransitioning then
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

    camera:update()
end

-- Called after calling update each frame.
function love.draw()
    local scale = love.graphics.getWidth() / world.levelWidth
    love.graphics.scale(scale)

    camera:draw()

    world:draw()
end
