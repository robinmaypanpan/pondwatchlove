local class = require('middleclass')

local Layer = require('ldtk2.Layer')

-- Super class for all layers
local EntityLayer = class('EntityLayer', Layer)

function EntityLayer:initialize(data, tilesets)
    Layer.initialize(self, data, tilesets)

    self.entities = {}
end

return EntityLayer