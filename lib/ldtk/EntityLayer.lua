local class = require('lib/middleclass')

local EntityLayer = class('EntityLayer')

function EntityLayer:initialize(data, builder)
    self.entities = {}
    self.data = data

    self.id = data.__identifier
    self.opacity = data.opacity
    self.visible = data.visible

    for _, entityData in ipairs(data.entitiyInstances) do
        local entity = {
            id = data.__identifier,
            x = data.__worldX,
            y = data.__worldY,
            tags = data.__tags,
            data = entityData
        }
        table.insert(self.entities, entity)
    end
end

function EntityLayer:renderDrawable()

end

return EntityLayer
