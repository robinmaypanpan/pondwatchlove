local class = require('lib/middleclass')

local Player = class('Player')

local MoveSpeed = 2

local PlayerWidth = 24
local PlayerHeight = 24

local CollisionType = {
    None = 0,
    Wall = 1,
    OutsideLevel = 2
}

function Player:initialize(data, level)
    self.level = level
    self.data = data

    self.id = data.__identifier
    self.x = data.__worldX
    self.y = data.__worldY

    self.image = love.graphics.newImage('assets/tilesets/pixel-platformer-characters.png')
    self.quad = love.graphics.newQuad(0, 0, PlayerWidth, PlayerHeight, self.image:getWidth(), self.image:getHeight())
end

-- Checks for collision at the indicated position
function Player:checkCollision(x, y)
    if not self.level:isWithinLevel(x, y) then
        return CollisionType.OutsideLevel
    end

    local collisionLayer = self.level:getLayer('Collision')
    local collideTile = collisionLayer:getTileInWorld(x, y)
    if collideTile.value == 1 then
        return CollisionType.Wall
    else
        return CollisionType.None
    end
end

-- Check for collisions in all the right places
function Player:checkForCollisions(x, y)
    local results = {}

    table.insert(results, self:checkCollision(x, y))
    table.insert(results, self:checkCollision(x + PlayerWidth, y))
    table.insert(results, self:checkCollision(x, y + PlayerHeight))
    table.insert(results, self:checkCollision(x + PlayerWidth, y + PlayerHeight))

    for _, result in ipairs(results) do
        if result == CollisionType.Wall then
            return result
        end
    end

    for _, result in ipairs(results) do
        if result == CollisionType.OutsideLevel then
            return result
        end
    end

    return CollisionType.None
end

function Player:update(updates)
    if updates.moveLeft then
        local result = self:checkForCollisions(self.x - MoveSpeed, self.y)
        if result ~= CollisionType.Wall then
            self.x = self.x - MoveSpeed
        end
        if result == CollisionType.OutsideLevel then
            self:changeLevels()
            return
        end
    elseif updates.moveRight then
        local result = self:checkForCollisions(self.x + MoveSpeed, self.y)
        if result ~= CollisionType.Wall then
            self.x = self.x + MoveSpeed
        end
        if result == CollisionType.OutsideLevel then
            self:changeLevels()
            return
        end
    end

    if updates.moveUp then
        local result = self:checkForCollisions(self.x, self.y - MoveSpeed)
        if result ~= CollisionType.Wall then
            self.y = self.y - MoveSpeed
        end
        if result == CollisionType.OutsideLevel then
            self:changeLevels()
            return
        end
    elseif updates.moveDown then
        local result = self:checkForCollisions(self.x, self.y + MoveSpeed)
        if result ~= CollisionType.Wall then
            self.y = self.y + MoveSpeed
        end
        if result == CollisionType.OutsideLevel then
            self:changeLevels()
            return
        end
    end
end

-- Used to trigger a level change
function Player:changeLevels()
    local newLevel = world:getLevelAt(self.x, self.y)

    if newLevel == nil then
        -- do nothing
        return
    end

    local oldLevel = self.level
    local entityLayer = oldLevel:getLayer('Entities')
    entityLayer:unbindEntity(self)

    local newLevel = world:getLevelAt(self.x, self.y)
    self.level = newLevel
    entityLayer = newLevel:getLayer('Entities')
    entityLayer:bindEntity(self)

    world:setActiveLevel(newLevel.id)
end

function Player:draw()
    love.graphics.draw(self.image, self.quad, self.x, self.y)
end

return Player
