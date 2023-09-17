local json = require('json')
local class = require('middleclass')

local getFields = require('ldtk2.getFields')

local Tileset = require('ldtk2.Tileset')
local EnumSet = require('ldtk2.EnumSet')
-- local TileLayer = require('ldtk2.TileLayer')

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

-- Returns a list of enums
function extractEnums(data, tilesets)
    local enumSets = {}
    for _, enumSetData in ipairs(data) do
        local enumSet = EnumSet:new(enumSetData, tilesets)

        enumSets[enumSet.id] = enumSet
        enumSets[enumSet.uid] = enumSet
    end
end

-- Extract and create all the layers that need to be rendered
function extractLayers(data, tilesets)
    local layers = {}

    for _,layerData in ipairs(data) do
        local layer
        if layerData.__type == 'IntGrid' then
            layer = IntLayer:new(layerData)
        elseif layerData.__type == 'Tiles' or layerData.__type == 'AutoLayer' then
            layer = TileLayer:new(layerData)
        elseif layerData.__type == 'Entities' then
            layer = EntityLayer:new(layerData)
        end

        table.insert(layers, layer)
    end

    return layers
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
    self.enums = extractEnums(data.defs.enums, self.tilesets)
    -- self.layers = extractLayers(data.defs.layers, self.tilesets)
    -- self.levels = extractLevels(data.levels)
end

-- Executes any updates in the world and makes sure updates
-- are sent to all children
function World:update(dt)
end

-- Draws the world
function World:draw()
end

return World