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

-- Used to check the corners for collision
function Player:checkCornerCollision(x, y)
    local collisionLayer = self.level:getLayer('Collision')

    local collideTile = collisionLayer:getTileInWorld(x, y)
    if collideTile and collideTile.value > 0 then return false end
    collideTile = collisionLayer:getTileInWorld(x + PlayerWidth, y)
    if collideTile and collideTile.value > 0 then return false end
    collideTile = collisionLayer:getTileInWorld(x, y + PlayerWidth)
    if collideTile and collideTile.value > 0 then return false end
    collideTile = collisionLayer:getTileInWorld(x + PlayerWidth, y + PlayerWidth)
    if collideTile and collideTile.value > 0 then return false end
    return true
end

function Player:update(updates)
    if updates.moveLeft then
        if self:checkCornerCollision(self.x - MoveSpeed, self.y) then
            self.x = self.x - MoveSpeed
        end
    elseif updates.moveRight then
        if self:checkCornerCollision(self.x + MoveSpeed, self.y) then
            self.x = self.x + MoveSpeed
        end
    end

    if updates.moveUp then
        if self:checkCornerCollision(self.x, self.y - MoveSpeed) then
            self.y = self.y - MoveSpeed
        end
    elseif updates.moveDown then
        if self:checkCornerCollision(self.x, self.y + MoveSpeed) then
            self.y = self.y + MoveSpeed
        end
    end
end

function Player:draw()
    love.graphics.draw(self.image, self.quad, self.x, self.y)
end

return Player
