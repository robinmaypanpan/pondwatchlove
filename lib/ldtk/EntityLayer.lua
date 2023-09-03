local class = require('lib/middleclass')

local EntityLayer = class('EntityLayer')

function EntityLayer:initialize(data, builder, level)
    self.entities = {}
    self.data = data
    self.level = level

    self.id = data.__identifier
    self.opacity = data.opacity
    self.visible = data.visible

    for _, entityData in ipairs(data.entityInstances) do
        local entity = builder:createEntity(entityData, level)
        table.insert(self.entities, entity)
    end
end

-- Binds an entity controller to the local entity data
function EntityLayer:bindEntity(entity)
    table.insert(self.entities, entity)
end

-- Unbinds an entity from the local entity table
function EntityLayer:unbindEntity(entity)
    table.removeItem(self.entities, entity)
end

-- Render a drawable associated with this layer
function EntityLayer:draw()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end

return EntityLayer
