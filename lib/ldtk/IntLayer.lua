local class = require('lib/middleclass')

local TileLayer = require('lib/ldtk/TileLayer')

local IntLayer = class('IntLayer', TileLayer)

function IntLayer:initialize(data, builder)
    TileLayer.initialize(self, data, builder)

    self.intGrid = {}
    local index = 1

    for row = 1, self.numRows do
        self.intGrid[row] = {}
        for col = 1, self.numCols do
            self.intGrid[row][col] = data.intGridCsv[index]
            index = index + 1
        end
    end
end

return IntLayer
