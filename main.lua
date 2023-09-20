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

    local filename = 'assets/levels/world.ldtk'
    if arg and #arg > 1 then
        filename = arg[2]
    end

    world = World:new()

    world:configure({
        activateAllLevels = true,
        loadAllOnCreation = true,
        entityTable = entityTable
    })
    
    world:loadFromFile(filename)

    love.window.setTitle('Garden Love')
    love.window.setMode(1280, 720, {
        fullscreen = false
    })
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- world:setActiveLevels({'Entrance'})

    -- -- Create our window locked canvases
    -- uiCanvas = love.graphics.newCanvas()
    -- backgroundCanvas = love.graphics.newCanvas()
end

local function processInput(dt)
    local spd = 800

    local moveLeft = love.keyboard.isDown('a') or love.keyboard.isDown('left')
    local moveRight = love.keyboard.isDown('d') or love.keyboard.isDown('right')
    local moveUp = love.keyboard.isDown('w') or love.keyboard.isDown('up')
    local moveDown = love.keyboard.isDown('s') or love.keyboard.isDown('down')

    local camera = world:getCamera()

    if moveLeft then
        camera.x = camera.x - spd * dt
    elseif moveRight then
        camera.x = camera.x + spd * dt
    end
    if moveUp then
        camera.y = camera.y - spd * dt
    elseif moveDown then
        camera.y = camera.y + spd * dt
    end
end

-- Called before calling draw each time a frame updates
function love.update(dt)
    flux.update(dt)
    local currentTime = love.timer.getTime()

    processInput(dt)

    world:update(dt)

    -- -- Clear canvas layers
    -- uiCanvas:renderTo(function()
    --     love.graphics.clear()
    -- end)
    -- backgroundCanvas:renderTo(function()
    --     love.graphics.clear()
    -- end)
end

-- Called after calling update each frame.
function love.draw()
    -- love.graphics.origin()
    -- love.graphics.draw(backgroundCanvas)

    world:draw()

    --drawDebug()

    -- love.graphics.origin()
    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.draw(uiCanvas)
end
