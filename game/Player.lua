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

-- returns true if the world x and y coordinates provided are within this level
function Player:isWithinLevel(x, y)
    return x >= self.level.x and y >= self.level.y
        and x < self.level.x + self.level.width
        and y < self.level.y + self.level.height
end

-- Checks for collision at the indicated position
function Player:checkCollision(x, y)
    if not self:isWithinLevel(x, y) then
        return false
    end

    local collisionLayer = self.level:getLayer('Collision')
    local collideTile = collisionLayer:getTileInWorld(x, y)
    return collideTile.value == 1
end

-- Used to check the corners for collision
function Player:checkCornerCollision(x, y)
    if self:checkCollision(x, y) then return true end
    if self:checkCollision(x + PlayerWidth, y) then return true end
    if self:checkCollision(x, y + PlayerHeight) then return true end
    if self:checkCollision(x + PlayerWidth, y + PlayerHeight) then return true end

    return false
end

function Player:update(updates)
    if updates.moveLeft then
        if not self:checkCornerCollision(self.x - MoveSpeed, self.y) then
            self.x = self.x - MoveSpeed
        end
    elseif updates.moveRight then
        if not self:checkCornerCollision(self.x + MoveSpeed, self.y) then
            self.x = self.x + MoveSpeed
        end
    end

    if updates.moveUp then
        if not self:checkCornerCollision(self.x, self.y - MoveSpeed) then
            self.y = self.y - MoveSpeed
        end
    elseif updates.moveDown then
        if not self:checkCornerCollision(self.x, self.y + MoveSpeed) then
            self.y = self.y + MoveSpeed
        end
    end
end

function Player:draw()
    love.graphics.draw(self.image, self.quad, self.x, self.y)
end

return Player
