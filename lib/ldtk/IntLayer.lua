local class = require('lib/middleclass')

local TileLayer = require('lib/ldtk/TileLayer')

local IntLayer = class('IntLayer', TileLayer)

function IntLayer:initialize(data, builder, level)
    TileLayer.initialize(self, data, builder, level)

    self.intGrid = {}

    for row = 0, self.numRows - 1 do
        self.intGrid[row] = {}
        for col = 0, self.numCols - 1 do
            local index = row * self.numRows + col % self.numRows + 1
            self.intGrid[row][col] = data.intGridCsv[index]
            assert(data.intGridCsv[index] ~= nil,
                'Missing int grid value for ' .. row .. ', ' .. col .. ' in layer ' .. self.id)
            print('Set collision ' .. row .. ',' .. col .. ' to ' .. data.intGridCsv[index])
        end
    end
end

-- Returns the grid value at a given location
function IntLayer:getTile(row, col)
    assert(row >= 0, "row is too low")
    assert(col >= 0, 'col is too low')
    assert(row < self.numRows, 'row is too high')
    assert(col < self.numCols, 'col is too high')

    return {
        value = self.intGrid[row][col],
        x = row * self.tileSize,
        y = col * self.tileSize,
        worldX = row * self.tileSize + self.level.x,
        worldY = col * self.tileSize + self.level.y
    }
end

-- Returns the tile at the specified x,y level coordinates
function IntLayer:getTileInLevel(x, y)
    local row = math.floor(y / self.tileSize)
    local col = math.floor(x / self.tileSize)

    assert(x >= 0, "X value is too low")
    assert(y >= 0, 'Y value is too low')
    assert(x < self.level.width, 'x value is too high')
    assert(y < self.level.height, 'y value is too high')

    print('Obtaining tile in level at ' .. x .. ', ' .. y)
    return self:getTile(row, col)
end

-- Returns the tile at the specified x,y world coordinates
function IntLayer:getTileInWorld(x, y)
    return self:getTileInLevel(x - self.level.x, y - self.level.y)
end

return IntLayer
