local class = require('lib/middleclass')

local EntityLayer = class('EntityLayer')

function EntityLayer:initialize(data, builder, level)
    self.entities = {}
    self.data = data

    self.id = data.__identifier
    self.opacity = data.opacity
    self.visible = data.visible

    for _, entityData in ipairs(data.entityInstances) do
        local entity = builder:createEntity(entityData)
        table.insert(self.entities, entity)
    end
end

-- Binds an entity controller to the local entity data
function EntityLayer:bindEntity(controller)
end

-- Render a drawable associated with this layer
function EntityLayer:draw()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end

return EntityLayer
