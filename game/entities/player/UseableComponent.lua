local class = require('lib/middleclass')

local UseableComponent = class('UseableComponent')

local Range = 20

function UseableComponent:initialize(player)
    self.player = player
end

-- Returns all entities in range that can be used
function UseableComponent:getClosestUseableEntityInRange()
    local entityLayer = self.player.level:getLayer('Entities')

    local centerX = self.player.x + self.player.width / 2
    local centerY = self.player.y + self.player.height / 2

    local closestEntity = nil
    local closestDistance = 9999999

    for _, entity in ipairs(entityLayer.entities) do
        local entityCenterX = entity.x + entity.width / 2
        local entityCenterY = entity.y + entity.height / 2

        local distance = math.distance(centerX, centerY, entityCenterX, entityCenterY)
        if distance < closestDistance and entity ~= self.player and entity.use then
            closestDistance = distance
            closestEntity = entity
        end
    end

    return closestEntity
end

function UseableComponent:update(updates)
    if updates.use then
        if self.player.carry:hasItem() then
            self.player.carry:useItem()
        else
            local entity = self:getClosestUseableEntityInRange()
            if entity then
                entity:use(self.player)
            end
        end
    end
end

function UseableComponent:changeLevel(oldLevel, newLevel)
end

function UseableComponent:draw()
end

return UseableComponent
