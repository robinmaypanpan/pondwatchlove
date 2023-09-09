local class = require('lib/middleclass')
local TileLayer = require('lib/ldtk/TileLayer')
local EntityLayer = require('lib/ldtk/EntityLayer')
local IntLayer = require('lib/ldtk/IntLayer')
local colorFromValue = require('lib/colorFromValue')
local fixRelPath = require('lib/ldtk/fixRelPath')
local getFields = require('lib/ldtk/getFields')

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

    self.fields = getFields(data)

    local bgColor = data.bgColor or data.__bgColor

    self.background = {
        color = bgColor,
    }

    if data.bgRelPath then
        local bgPath = fixRelPath(data.bgRelPath)
        self.background.image = love.graphics.newImage(bgPath)
        self.background.position = data.bgPos
        self.background.pivotX = data.bgPivotX
        self.background.pivotY = data.bgPivotY
    end

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

-- Converts world-relative x,y coordinates to level-relative x,y coordinates
function Level:convertWorldToLevel(x, y)
    return x - self.x, y - self.y
end

-- Converts level-relative x,y coordinates to world-relative x,y coordinates
function Level:convertLevelToWorld(x, y)
    return x + self.x, y + self.y
end

-- Calculate the correct position based on the pivot
function calculatePivot(pivot, source, destination)
    return destination * pivot - source * pivot
end

-- Draws the background to the various layers
function Level:drawBackground()
    if self.fields.LockBGToCamera then
        -- Defer background drawing to camera
        return
    end

    local bg = self.background

    if bg.image then
        if bg.position == 'Repeat' then
            -- TODO: Implementing repeating backgrounds
        else
            local scaleX, scaleY, x, y
            if bg.position == 'Cover' then
                scaleX = self.width / bg.image:getWidth()
                scaleY = self.height / bg.image:getHeight()
                scaleX = math.max(scaleX, scaleY)
                scaleY = scaleX
            elseif bg.position == 'Contain' then
                scaleX = self.width / bg.image:getWidth()
                scaleY = self.height / bg.image:getHeight()
                scaleX = math.min(scaleX, scaleY)
                scaleY = scaleX
            elseif bg.position == 'CoverDirty' then
                scaleX = self.width / bg.image:getWidth()
                scaleY = self.height / bg.image:getHeight()
            elseif bg.position == 'Unscaled' then
                scaleX = 1
                scaleY = 1
            end
            x = calculatePivot(bg.pivotX, scaleX * bg.image:getWidth(), self.width)
            y = calculatePivot(bg.pivotY, scaleY * bg.image:getHeight(), self.height)

            createStencil = function()
                love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            end

            love.graphics.stencil(createStencil, "replace", 1)
            -- Only allow rendering on pixels which have a stencil value greater than 0.
            love.graphics.setStencilTest("greater", 0)
            love.graphics.setColor(1, 1, 1, 1);
            love.graphics.draw(bg.image, self.x + x, self.y + y, 0, scaleX, scaleY, bg.pivotX, bg.pivotY)
            love.graphics.setStencilTest()
        end
    else
        love.graphics.setColor(colorFromValue(bg.color))
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end
end

-- Draws this level at the indicated position
function Level:draw()
    self:drawBackground()

    love.graphics.setColor(1, 1, 1, 1);
    for _, layer in ipairs(self.drawLayers) do
        if layer.visible then
            layer:draw()
        end
    end
end

return Level
