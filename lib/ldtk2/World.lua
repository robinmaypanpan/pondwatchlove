local json = require('lib/json')
local class = require('lib/middleclass')

local getFields = require('lib/ldtk2/getFields')

local Tileset = require('lib/ldtk2/Tileset')

-- Extracts the settings for the world
function configureWorld(world, data)
    -- Store a raw copy of the data
    world.data = data

    -- The grid size when dealing with a grid vania
    world.gridWidth = data.worldGridWidth
    world.gridHeight = data.worldGridHeight

    -- Store arbitrary fields
    world.fields = getFields(data)
end

-- Returns a list of tileset objects configured with provided data
function extractTilesets(data)
    local tilesets = {}
    for _, tilesetData in ipairs(data) do
        if tilesetData.relPath then
            local tileset = Tileset:new(tilesetData)
            tilesets[tileset.id] = tileset
            tilesets[tileset.uid] = tileset
        end
    end
    return tilesets
end

-- Represents a single LDTK world
local World = class('World')

function World:initialize(entityTable)
    self.tilesets = {}
    self.layers = {}
    self.levels = {}
    self.entityTable = entityTable

    self.activeLevels = {}
end

-- Loads the world from an ldtk file
function World:loadFromFile(filename)
    assert(love.filesystem.getInfo(filename), "Level file " .. filename .. " does not exist")

    local rawData = love.filesystem.read(filename)

    local data = json.decode(rawData)
    
    configureWorld(self, data)

    self.tilesets = extractTilesets(data.defs.tilesets)

end

-- Executes any updates in the world and makes sure updates
-- are sent to all children
function World:update(dt)
end

-- Draws the world
function World:draw()
end

return World