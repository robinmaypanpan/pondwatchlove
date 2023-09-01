if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local LevelBuilder = require('lib/ldtk/LevelBuilder')
local builder = LevelBuilder:new()

function love.load()
    love.window.setTitle('Garden Love')
    love.window.setMode(1920, 1080, {
        fullscreen = false
    })
    world = builder:load('assets/levels/test1.ldtk')

    world:displayLevel('Entrance')
end

-- Called before calling draw each time a frame updates
function love.update()
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
