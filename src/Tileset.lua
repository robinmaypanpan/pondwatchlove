local class = require('lib/middleclass')

local Tileset = class('Tileset')

-- Adjust the relative path so it points from the root
function fixRelPath(path)
    local result, _ = string.gsub(path, '../', 'assets/')
    return result
end

function Tileset:initialize(data)
    print(data)
    self.data = data

    self.id = data.identifier
    self.uid = data.uid

    self.tileSize = data.tileGridSize
    self.spacing = data.spacing
    self.padding = data.padding
    self.imageSource = love.graphics.newImage(fixRelPath(data.relPath))
end

function Tileset:getTileQuad()
    -- Get "grid-based" coordinate of the tileId
    -- local gridTileX = tileId - atlasGridBaseWidth * Std.int(tileId / atlasGridBaseWidth);

    -- -- Get the atlas pixel coordinate
    -- local pixelTileX = padding + gridTileX * (gridSize + spacing);

    -- -- Get "grid-based" coordinate of the tileId
    -- local gridTileY = Std.int(tileId / atlasGridBaseWidth)

    -- -- Get the atlas pixel coordinate
    -- local pixelTileY = padding + gridTileY * (gridSize + spacing);
end

return Tileset
