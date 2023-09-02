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
    world = builder:load('assets/levels/world.ldtk')

    world:activateLevel('Entrance')
end

-- Called before calling draw each time a frame updates
function love.update()
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
    local scale = love.graphics.getWidth() / 600
    love.graphics.scale(scale)
    love.graphics.translate(-(player.x - 300), -(player.y - 150))

    world:draw()
end
