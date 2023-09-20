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

    local filename = 'assets/levels/parallax_world.ldtk'
    if arg and #arg > 1 then
        filename = arg[2]
    end

    world = World:new()

    world:configure({
        loadAllOnCreation = true,
        entityTable = entityTable,
        lockCameraToCurrentLevel = true
    })

    world:loadFromFile(filename)

    world:configureCamera({
        movement = 'dampen',
        centerTarget = true,
        dampValue = 4,
        levelZoom = 1,
        tweenSpeed = 0.4,
        tweenEase = 'quintinout'
    })

    world:setCurrentLevel('Entrance')

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
    print('mousepressed at ' .. screenX .. ', ' .. screenY)
    if button == 1 then
        Mouse1IsDown = true
        local camera = world:getCamera()
        local worldX, worldY = camera:screenToWorld(screenX, screenY)
        camera:setTarget(worldX, worldY)
    elseif button == 2 then
        if world:getCurrentLevel().id == 'Entrance' then
            world:prepareLevelTransitionTo('Level_2')
            world:getCamera():moveTo(world.newLevel.x, world.newLevel.y)
                :oncomplete(function()
                    world:completeLevelTransition()
                end)
        else
            world:prepareLevelTransitionTo('Entrance')
            world:getCamera():moveTo(world.newLevel.x, world.newLevel.y)
                :oncomplete(function()
                    world:completeLevelTransition()
                end)
        end
    end
end

function love.mousemoved(screenX, screenY, dx, dy, istouch)
    if Mouse1IsDown then
        local camera = world:getCamera()
        local worldDX, worldDY = camera:screenDeltaToWorld(dx, dy)
        camera:move(-worldDX, -worldDY)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        Mouse1IsDown = false
    end
end

function love.wheelmoved(x, y)
    local camera = world:getCamera()
    camera:setZoom(camera.zoom + y / 10)
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
