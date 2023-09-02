local class = require('lib/middleclass')

-- A Tileset is a collection of images that can be used for sprite batches and other sources
local Tileset = class('Tileset')

-- Adjust the relative path so it points from the root
function fixRelPath(path)
    local result, _ = string.gsub(path, '%.%./', 'assets/')
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

    self.numRows = data.__cHei
    self.numCols = data.__cWid

    self.width = data.pxWid
    self.height = data.pxHei

    self.imageSource = love.graphics.newImage(fixRelPath(data.relPath))

    local numTiles = self.numRows * self.numCols
    self.tileQuads = {}
end

-- Create or retrieve a tile quad for a given tile
function Tileset:getTileQuad(tileId)
    if self.tileQuads[tileId] == nil then
        -- Get "grid-based" coordinate of the tileId
        local gridTileX = tileId - self.numCols * math.floor(tileId / self.numCols);

        -- Get the atlas pixel coordinate
        local pixelTileX = self.padding + gridTileX * (self.tileSize + self.spacing);

        -- Get "grid-based" coordinate of the tileId
        local gridTileY = math.floor(tileId / self.numCols)

        -- Get the atlas pixel coordinate
        local pixelTileY = self.padding + gridTileY * (self.tileSize + self.spacing);

        self.tileQuads[tileId] = love.graphics.newQuad(pixelTileX, pixelTileY,
            self.tileSize, self.tileSize,
            self.width, self.height)
    end

    return self.tileQuads[tileId]
end

-- Returns a SpriteBatch object
function Tileset:createSpriteBatch(numRows, numCols)
    local spriteBatch = love.graphics.newSpriteBatch(self.imageSource, numRows * numCols)
    return spriteBatch
end

return Tileset
