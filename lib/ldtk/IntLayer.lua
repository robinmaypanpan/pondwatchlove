local class = require('lib/middleclass')

local TileLayer = require('lib/ldtk/TileLayer')

local IntLayer = class('IntLayer', TileLayer)

function IntLayer:initialize(data, builder, level)
    TileLayer.initialize(self, data, builder, level)

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
end

-- Returns the grid value at a given location
function IntLayer:getTile(row, col)
    if row < 0 or col < 0 or row >= self.numRows or col >= self.numCols then
        return nil
    end

    local tile = TileLayer.getTile(self, row, col)

    local tileData = {
        tileId = tile and tile.id,
        value = self.intGrid[row][col],
        x = row * self.tileSize,
        y = col * self.tileSize,
        worldX = row * self.tileSize + self.level.x,
        worldY = col * self.tileSize + self.level.y
    }

    return tileData
end

return IntLayer
