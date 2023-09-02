if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

require('lib/table')
local LevelBuilder = require('lib/ldtk/LevelBuilder')
local Player = require('game/Player')

local entityTable = {
    Player = function(data)
        player = Player:new(data)
        return player
    end
}

function love.load()
    love.window.setTitle('Garden Love')
    love.window.setMode(1920, 1080, {
        fullscreen = false
    })

    local builder = LevelBuilder:new(entityTable)
    world = builder:load('assets/levels/test1.ldtk')

    world:activateLevel('Entrance')
end

-- Called before calling draw each time a frame updates
function love.update()
    if player then
        local moveLeft = love.keyboard.isDown('a') or love.keyboard.isDown('left')
        local moveRight = love.keyboard.isDown('d') or love.keyboard.isDown('right')
        local jump = love.keyboard.isDown('space')

        player:update({
            moveLeft = moveLeft,
            moveRight = moveRight,
            jump = jump
        })
    end
end

-- Called after calling update each frame.
function love.draw()
    local canvas = love.graphics.newCanvas(world.levelWidth, world.levelHeight)
    love.graphics.setCanvas(canvas)
    world:draw()
    love.graphics.setCanvas()

    local scale = love.graphics.getWidth() / 600
    love.graphics.scale(scale)

    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.draw(canvas, 0, 0)
end
