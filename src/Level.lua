local class = require('lib/middleclass')
local TileLayer = require('src/TileLayer')
local colorFromValue = require('lib/colorFromValue')

local Level = class('Level')

function Level:initialize(data, builder)
    self.data = data

    self.id = data.identifier
    self.uid = data.uid

    self.x = data.worldX
    self.y = data.worldY
    self.width = data.pxWid
    self.height = data.pxHei

    self.bgColor = data.bgColor or data.__bgColor

    self.layers = {}

    for _, layerData in pairs(data.layerInstances) do
        if layerData.__type == 'IntGrid' then
            local layer = TileLayer:new(layerData, builder)

            table.insert(self.layers, layer)
        elseif layerData.__type == 'Tiles' or layerData.__type == 'AutoLayer' then
            local layer = TileLayer:new(layerData, builder)

            table.insert(self.layers, layer)
        end
    end
end

-- Draws this level at the indicated position
function Level:draw()
    love.graphics.setColor(colorFromValue(self.bgColor))
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    love.graphics.setColor(1, 1, 1, 1);
    for _, layer in ipairs(self.layers) do
        if layer.visible then
            local drawable = layer:renderDrawable()
            love.graphics.draw(drawable, self.x, self.y)
        end
    end
end

return Level
