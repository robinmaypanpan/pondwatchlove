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
        entityTable = entityTable,
        cameraSettings = {
            dampenMovement = true,
            centerTarget = true
        }
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

    local dx = 0
    local dy = 0

    if moveLeft then
        dx = -spd * dt
    elseif moveRight then
        dx = spd * dt
    end
    if moveUp then
        dy = -spd * dt
    elseif moveDown then
        dy = spd * dt
    end

    if dx ~= 0 or dy ~= 0 then
        world:getCamera():move(dx, dy)
    end
end

function love.mousepressed(screenX, screenY, button, istouch, presses)
    if button == 1 then
        Mouse1IsDown = true
        local camera = world:getCamera()
        local worldX, worldY = camera:screenToWorld(screenX, screenY)
        camera:setTarget(worldX, worldY)
    end
end

function love.mousemoved(screenX, screenY, dx, dy, istouch)
    if Mouse1IsDown then
        local camera = world:getCamera()
        camera:move(dx, dy)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        Mouse1IsDown = false
    end
end

-- Called before calling draw each time a frame updates
function love.update(dt)
    flux.update(dt)

    processInput(dt)

    world:update(dt)
end

-- Called after calling update each frame.
function love.draw()
    world:draw()
end
