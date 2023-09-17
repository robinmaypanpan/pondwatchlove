local class = require('middleclass')

-- An enum set is a collection of enums with various values
local EnumSet = class('EnumSet')

function EnumSet:initialize(data, tilesets)
    self.data = data
    self.id = data.identifier
    self.uid = data.uid

    self.values = {}

    for _, enumValueData in ipairs(data.values) do
        local tileset = tilesets[enumValueData.tileRect.tilesetUid]
        local newValue = {
            id = enumValueData.id,
            tileset = tileset,
            quad = tileset:getTileQuadByData(enumValueData.tileRect),
            width = enumValueData.tileRect.w,
            height = enumValueData.tileRect.h,
        }
        self.values[newValue.id] = newValue
    end
end

return EnumSet