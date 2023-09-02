local class = require('lib/middleclass')

local Player = class('Player')

local MoveSpeed = 2

local PlayerWidth = 24
local PlayerHeight = 24

function Player:initialize(data, level)
    self.level = level
    self.data = data

    self.id = data.__identifier
    self.x = data.__worldX
    self.y = data.__worldY

    self.image = love.graphics.newImage('assets/tilesets/pixel-platformer-characters.png')
    self.quad = love.graphics.newQuad(0, 0, PlayerWidth, PlayerHeight, self.image:getWidth(), self.image:getHeight())
end

function Player:update(updates)
    local collisionLayer = self.level:getLayer('Collision')

    if updates.moveLeft then
        self.x = self.x - MoveSpeed
    elseif updates.moveRight then
        self.x = self.x + MoveSpeed
    end

    if updates.moveUp then
        self.y = self.y - MoveSpeed
    elseif updates.moveDown then
        self.y = self.y + MoveSpeed
    end

    local collideTile = collisionLayer:getTileInWorld(self.x, self.y)

    print('Collisions at ' .. collideTile.value .. ' and ' .. collideTile.value)
end

function Player:draw()
    love.graphics.draw(self.image, self.quad, self.x, self.y)
end

return Player
