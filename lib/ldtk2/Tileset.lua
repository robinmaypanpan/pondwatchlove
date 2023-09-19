local class = require('lib/middleclass')
local fixRelPath = require('lib/ldtk2/fixRelPath')

-- A Tileset is a collection of images arranged in a gridlike fashion
local Tileset = class('Tileset')

function Tileset:initialize(data)
    self.data = data

    self.id = data.identifier
    self.uid = data.uid

    self.tileSize = data.tileGridSize

    -- Distance between tiles
    self.spacing = data.spacing
    self.padding = data.padding

    -- Number of rows and columns of tiles
    self.numRows = data.__cHei
    self.numCols = data.__cWid

    self.width = data.pxWid
    self.height = data.pxHei

    self.isLoaded = false

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
        -- This is a quad that is not associated with a single tile
        return love.graphics.newQuad(tileData.x, tileData.y,
            tileData.w, tileData.h,
            self.width, self.height)
    end
end

-- Create or retrieve a tile quad for a given tile
function Tileset:getTileQuad(tileId)
    -- First, create the quad if it doesn't already exist
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

-- Draws the indicated tile
function Tileset:drawTile(tileId, ...)
    local quad = self:getTileQuad(tileId)
    love.graphics.draw(self.imageSource, quad, ...)
end

-- Load the image associated with this tileset into memory
function Tileset:load()
    self.imageSource = love.graphics.newImage(fixRelPath(self.data.relPath))
    self.imageSource:setFilter("nearest", "nearest")
    self.isLoaded = true
end

-- Returns a SpriteBatch object
function Tileset:createSpriteBatch(numRows, numCols)
    assert(self.isLoaded, 'Tileset ' .. self.id .. ' not loaded')
    local spriteBatch = love.graphics.newSpriteBatch(self.imageSource, numRows * numCols)
    return spriteBatch
end

return Tileset