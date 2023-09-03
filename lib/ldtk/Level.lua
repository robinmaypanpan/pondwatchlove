local class = require('lib/middleclass')
local TileLayer = require('lib/ldtk/TileLayer')
local EntityLayer = require('lib/ldtk/EntityLayer')
local IntLayer = require('lib/ldtk/IntLayer')
local colorFromValue = require('lib/colorFromValue')

local Level = class('Level')

function Level:initialize(data, builder)
    print('Creating level ' .. data.identifier)
    self.data = data

    self.id = data.identifier
    self.uid = data.uid
    self.iid = data.iid

    self.neighbors = data.__neighbours

    self.x = data.worldX
    self.y = data.worldY
    self.width = data.pxWid
    self.height = data.pxHei

    self.bgColor = data.bgColor or data.__bgColor

    self.layers = {}
    self.drawLayers = {}

    --for _, layerData in ipairs(data.layerInstances) do
    for i = #data.layerInstances, 1, -1 do
        local layerData = data.layerInstances[i]
        local layer
        if layerData.__type == 'IntGrid' then
            layer = IntLayer:new(layerData, builder, self)
        elseif layerData.__type == 'Tiles' or layerData.__type == 'AutoLayer' then
            layer = TileLayer:new(layerData, builder, self)
        elseif layerData.__type == 'Entities' then
            layer = EntityLayer:new(layerData, builder, self)
        end

        -- Update our layer database for later access
        self.layers[layer.id] = layer

        -- Visible layers should be part of the render path
        if layer.visible then
            table.insert(self.drawLayers, layer)
        end
    end
end

-- Returns the layer with the indicated id
function Level:getLayer(layerId)
    return self.layers[layerId]
end

-- returns true if the world x and y coordinates provided are within this level
function Level:isWithinLevel(x, y)
    return x >= self.x and y >= self.y
        and x < self.x + self.width
        and y < self.y + self.height
end

-- Draws this level at the indicated position
function Level:draw()
    love.graphics.setColor(colorFromValue(self.bgColor))
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    love.graphics.setColor(1, 1, 1, 1);
    for _, layer in ipairs(self.drawLayers) do
        if layer.visible then
            layer:draw()
        end
    end
end

return Level
