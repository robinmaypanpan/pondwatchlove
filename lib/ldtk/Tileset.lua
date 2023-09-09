local class = require('lib/middleclass')
local fixRelPath = require('lib/ldtk/fixRelPath')

-- A Tileset is a collection of images that can be used for sprite batches and other sources
local Tileset = class('Tileset')

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
    self.imageSource:setFilter("nearest", "nearest")

    local numTiles = self.numRows * self.numCols
    self.tileQuads = {}
end

-- Returns a tile quad based on the provided x,y,w,h source
function Tileset:getTileQuadByData(tileData)
    if tileData.w == self.tileSize and tileData.h == self.tileSize then
        local col = (tileData.x - self.padding) / (self.tileSize + self.spacing)
        local row = (tileData.y - self.padding) / (self.tileSize + self.spacing)
        local tileId = col + self.numCols * row
        return self:getTileQuad(tileId)
    else
        return love.graphics.newQuad(tileData.x, tileData.y,
            tileData.w, tileData.h,
            self.width, self.height)
    end
end

-- Create or retrieve a tile quad for a given tile
function Tileset:getTileQuad(tileId)
    if self.tileQuads[tileId] == nil then
        -- Get "grid-based" coordinate of the tileId
        local col = tileId - self.numCols * math.floor(tileId / self.numCols);

        -- Get the atlas pixel coordinate
        local pixelTileX = self.padding + col * (self.tileSize + self.spacing);

        -- Get "grid-based" coordinate of the tileId
        local row = math.floor(tileId / self.numCols)

        -- Get the atlas pixel coordinate
        local pixelTileY = self.padding + row * (self.tileSize + self.spacing);

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
