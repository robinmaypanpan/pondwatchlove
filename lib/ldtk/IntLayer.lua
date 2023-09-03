local class = require('lib/middleclass')

local TileLayer = require('lib/ldtk/TileLayer')

local IntLayer = class('IntLayer')

function IntLayer:initialize(data, builder, level)
    self.level = level

    self.id = data.__identifier
    self.numRows = data.__cHei
    self.numCols = data.__cWid

    self.tileSize = data.__gridSize

    self.visible = data.visible
    self.opacity = data.__opacity

    local layerDef = builder:getLayerDefinition(self.id)

    self.intValues = {}
    self.intValues[0] = {
        id = 'Nothing',
        color = '#000000'
    }
    for _, gridValue in ipairs(layerDef.intGridValues) do
        self.intValues[gridValue.value] = {
            id = gridValue.identifier,
            color = gridValue.color
        }
    end

    self.intGrid = {}

    for row = 0, self.numRows - 1 do
        self.intGrid[row] = {}
        for col = 0, self.numCols - 1 do
            local index = row * self.numCols + col % self.numCols + 1
            self.intGrid[row][col] = data.intGridCsv[index]
            assert(data.intGridCsv[index] ~= nil,
                'Missing int grid value for ' .. row .. ', ' .. col .. ' in layer ' .. self.id)
        end
    end

    -- Check to see if we have a tile layer as part of ourself
    if data.autoLayerTiles and #data.autoLayerTiles > 0 then
        self.tileLayer = TileLayer:new(data, builder, level)
    end
end

-- Returns the grid value at a given location
function IntLayer:getTile(row, col)
    if row < 0 or col < 0 or row >= self.numRows or col >= self.numCols then
        return nil
    end

    local tileData = {
        value = self.intGrid[row][col],
        xLevel = row * self.tileSize,
        yLevel = col * self.tileSize,
        xWorld = row * self.tileSize + self.level.x,
        yWorld = col * self.tileSize + self.level.y
    }

    local intValue = self.intValues[tileData.value]
    assert(intValue ~= nil, 'Could not find intValue at ' .. row .. ', ' .. col .. ' for layer ' .. self.id)
    tileData.color = intValue.color
    tileData.id = intValue.id

    if self.tileLayer then
        local tile = self.tileLayer:getTile(row, col)
        if tile then
            tileData.tileId = tile.id
        end
    end

    return tileData
end

-- Returns the tile at the specified x,y level coordinates
function IntLayer:getTileInLevel(x, y)
    local row = math.floor(y / self.tileSize)
    local col = math.floor(x / self.tileSize)

    return self:getTile(row, col)
end

-- Returns the tile at the specified x,y world coordinates
-- NB: Returns nil outside the level
function IntLayer:getTileInWorld(x, y)
    return self:getTileInLevel(x - self.level.x, y - self.level.y)
end

-- This int layer can be drawn if it doesn't have tiles
function IntLayer:draw()
    if self.tileLayer then
        self.tileLayer:draw()
    else
        for row = 0, self.numRows - 1 do
            for col = 0, self.numCols - 1 do
                local tile = self:getTile(row, col)
                assert(tile ~= nil, 'Could not find tile at ' .. row .. ', ' .. col .. ' for layer ' .. self.id)
                local x = self.level.x + col * self.tileSize
                local y = self.level.y + row * self.tileSize
                if tile.value > 0 then
                    local r, g, b = colorFromValue(tile.color)
                    love.graphics.setColor(r, g, b, self.opacity)
                    love.graphics.rectangle('fill', x, y, self.tileSize, self.tileSize)
                end
            end
        end
    end
end

return IntLayer
