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
    love.graphics.setDefaultFilter('nearest', 'nearest')
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

    camera:update()
end

function drawStaticBackground()
    -- Early aborts
    if not player then return end
    if not player.level then return end
    if not player.level.background then return end

    local bg = player.level.background
    if bg.image and player.level.fields.LockBGToCamera then
        local scaleX, scaleY
        scaleX = world.levelWidth / bg.image:getWidth()
        scaleY = world.levelHeight / bg.image:getHeight()
        scaleX = math.max(scaleX, scaleY)
        scaleY = scaleX

        love.graphics.setColor(1, 1, 1, 1);
        love.graphics.draw(bg.image, 0, 0, 0, scaleX, scaleY, bg.pivotX, bg.pivotY)
    end
end

-- Called after calling update each frame.
function love.draw()
    local scale = love.graphics.getWidth() / world.levelWidth
    love.graphics.scale(scale)

    drawStaticBackground()

    camera:draw()

    world:draw()

    -- Draw character tiles
    love.graphics.setColor(0, 0, 1, 1)
    local playerTiles = player:getPlayerTiles(player.x, player.y)
    for _, tile in ipairs(playerTiles) do
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end

    -- Draw ground tiles
    love.graphics.setColor(0, 1, 0, 1)
    local groundTiles = player:getGroundTiles(player.x, player.y)
    for _, tile in ipairs(groundTiles) do
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end

    -- Draw collision tiles
    love.graphics.setColor(1, 0, 0, 1)
    local edgeTiles = player:getEdgeTiles('x', player.xSpeed)
    for _, tile in ipairs(edgeTiles) do
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end

    local edgeTiles = player:getEdgeTiles('y', player.ySpeed)
    for _, tile in ipairs(edgeTiles) do
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
    end
end
