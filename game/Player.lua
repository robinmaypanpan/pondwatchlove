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

    local newX = self.x
    local newY = self.y

    if updates.moveLeft then
        newX = self.x - MoveSpeed
    elseif updates.moveRight then
        newX = self.x + MoveSpeed
    end

    if updates.moveUp then
        newY = self.y - MoveSpeed
    elseif updates.moveDown then
        newY = self.y + MoveSpeed
    end

    local collideTile = collisionLayer:getTileInWorld(newX, newY)

    if collideTile.value == 0 then
        self.x = newX
        self.y = newY
    else
        print('Colliding at ' .. newX .. ', ' .. newY)
    end
end

function Player:draw()
    love.graphics.draw(self.image, self.quad, self.x, self.y)
end

return Player
