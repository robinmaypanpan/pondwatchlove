if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

require('lib/table')
require('lib/math')
require('lib/string')

local flux = require('lib/flux')

local Tiles = require('game/Tiles')

local World = require('lib/ldtk2/World')
local Camera = require('game/Camera')

local Player = require('game/entities/Player')
local Camp = require('game/entities/Camp')
local ItemDispenser = require('game/entities/ItemDispenser')
local Entity = require('game/entities/Entity')

local useTime
local useDelay = 0.5

local entityTable = {
    -- Player = function(data, level)
    --     assert(player == nil, "Player was already created")
    --     player = Player:new(data, level)
    --     return player
    -- end,
    -- Camp = function(data, level)
    --     local camp = Camp:new(data, level)
    --     return camp
    -- end,
    -- ItemDispenser = function(data, level)
    --     local itemDispenser = ItemDispenser:new(data, level)
    --     return itemDispenser
    -- end,
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

    -- useTime = love.timer.getTime()

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

    -- if player and not camera.isTransitioning then
    --     local moveLeft = love.keyboard.isDown('a') or love.keyboard.isDown('left')
    --     local moveRight = love.keyboard.isDown('d') or love.keyboard.isDown('right')
    --     local moveUp = love.keyboard.isDown('w') or love.keyboard.isDown('up')
    --     local moveDown = love.keyboard.isDown('s') or love.keyboard.isDown('down')

    --     local jump = love.keyboard.isDown('space')

    --     local useKeyDown = love.keyboard.isDown('e')
    --     local use = useKeyDown and currentTime - useTime > useDelay

    --     if use then
    --         useTime = currentTime
    --     end

    --     player:update({
    --         moveLeft = moveLeft,
    --         moveRight = moveRight,
    --         moveUp = moveUp,
    --         moveDown = moveDown,
    --         jump = jump,
    --         use = use
    --     })
    -- end

    -- camera:update()

    -- drawStaticBackground()
end

function drawStaticBackground()
    -- Early aborts
    if not player then return end
    if not player.level then return end
    if not player.level.background then return end

    local bg = player.level.background
    if bg.image and player.level.fields.LockBGToCamera then
        local scaleX, scaleY
        scaleX = backgroundCanvas:getWidth() / bg.image:getWidth()
        scaleY = backgroundCanvas:getHeight() / bg.image:getHeight()
        scaleX = math.max(scaleX, scaleY)
        scaleY = scaleX

        backgroundCanvas:renderTo(function()
            love.graphics.setColor(1, 1, 1, 1);
            love.graphics.draw(bg.image, 0, 0, 0, scaleX, scaleY, bg.pivotX, bg.pivotY)
        end)
    end
end

function drawDebug()
    local font = love.graphics.newFont(12)
    love.graphics.setFont(font)
    -- Draw ground tiles
    love.graphics.setColor(0, 1, 0, 1)
    local groundTiles = player:getGroundTiles(player.x, player.y)
    for _, tile in ipairs(groundTiles) do
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end

    -- Draw collision tiles
    love.graphics.setColor(1, 1, 0, 1)
    for _, tile in ipairs(player.xEdge) do
        love.graphics.print('TX: ' .. tile.x, player.x, player.y - 44)
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end

    love.graphics.setColor(1, 0, 1, 1)
    for _, tile in ipairs(player.yEdge) do
        love.graphics.print('TY: ' .. tile.x, player.x, player.y - 56)
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end

    -- Draw hitbox
    love.graphics.setColor(0, 0, 1, 1)
    local hitbox = player:getHitbox(player.x, player.y)
    love.graphics.rectangle('line', hitbox.x, hitbox.y, hitbox.width, hitbox.height)

    love.graphics.print('P:' .. player.x .. ',' .. player.y, player.x, player.y - 20)
    love.graphics.print('S:' .. player.xSpeed .. ',' .. player.ySpeed, player.x, player.y - 32)
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
