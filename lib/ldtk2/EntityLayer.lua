local class = require('middleclass')

local Layer = require('ldtk2.Layer')

-- Super class for all layers
local EntityLayer = class('EntityLayer', Layer)

function EntityLayer:initialize(data, layerDefinition, level)
    Layer.initialize(self, data, layerDefinition, level)

    self.entities = {}
end

return EntityLayer