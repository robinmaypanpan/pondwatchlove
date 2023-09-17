if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

require('lib/')

local flux = require('flux')

local World = require('ldtk2.World')

local Entity = require('game.entities.Entity')

local entityTable = {
    default = function(data, level)
        local entity = Entity:new(data, level)
        return entity
    end
}

function love.load(arg)
    love.window.setTitle('Garden Love')
    love.window.setMode(1280, 720, {
        fullscreen = false
    })
    love.graphics.setDefaultFilter('nearest', 'nearest')
    local filename = 'assets/levels/world.ldtk'
    if arg and #arg > 1 then
        filename = arg[2]
    end

    world = World:new(entityTable)
    world:loadFromFile(filename)

    -- world:setActiveLevel('Entrance')

    -- camera = Camera:new(player, world)

    -- -- Create our window locked canvases
    -- uiCanvas = love.graphics.newCanvas()
    -- backgroundCanvas = love.graphics.newCanvas()
end

local isLevelTransition = false

-- Called before calling draw each time a frame updates
function love.update(dt)
    flux.update(dt)
    local currentTime = love.timer.getTime()

    world:update(dt)

    -- -- Clear canvas layers
    -- uiCanvas:renderTo(function()
    --     love.graphics.clear()
    -- end)
    -- backgroundCanvas:renderTo(function()
    --     love.graphics.clear()
    -- end)

    -- camera:update()
end

-- Called after calling update each frame.
function love.draw()
    -- love.graphics.origin()
    -- love.graphics.draw(backgroundCanvas)

    local scale = love.graphics.getWidth() / world.gridWidth
    love.graphics.scale(scale)

    -- camera:draw()

    world:draw()

    --drawDebug()

    -- love.graphics.origin()
    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.draw(uiCanvas)
end
