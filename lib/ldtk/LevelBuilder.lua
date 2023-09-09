local json = require('lib/json')
local class = require('lib/middleclass')

local Level = require('lib/ldtk/Level')
local World = require('lib/ldtk/World')
local Tileset = require('lib/ldtk/Tileset')

local LevelBuilder = class('LevelBuilder')

function LevelBuilder:initialize(entityTable)
    self.tilesets = {}
    self.entityTable = entityTable
end

-- Creates an entity from the provided data
function LevelBuilder:createEntity(data, level)
    local id = data.__identifier
    if self.entityTable[id] then
        local entityGenerator = self.entityTable[id]
        return entityGenerator(data, level)
    end
    return nil
end

-- Returns the definition for the indicated layer
function LevelBuilder:getLayerDefinition(id)
    for _, layerData in ipairs(self.data.defs.layers) do
        if layerData.identifier == id then
            return layerData
        end
    end
end

function LevelBuilder:load(filename)
    assert(love.filesystem.getInfo(filename), "Level file " .. filename .. " does not exist")

    local fileData = love.filesystem.read(filename)

    self.data = json.decode(fileData)

    local world = World:new(self.data)

    -- Create sprite batches from tilesets
    for _, tilesetData in ipairs(self.data.defs.tilesets) do
        if tilesetData.relPath then
            local tileset = Tileset:new(tilesetData)
            self.tilesets[tileset.id] = tileset
            self.tilesets[tileset.uid] = tileset
        end
    end

    for _, levelData in ipairs(self.data.levels) do
        local realData = levelData
        if levelData.externalRelPath then
            local filename = 'assets/levels/' .. levelData.externalRelPath
            assert(love.filesystem.getInfo(filename), "Level file " .. filename .. " does not exist")

            local fileData = love.filesystem.read(filename)

            realData = json.decode(fileData)
        end
        local level = Level:new(realData, self)
        world:addLevel(level)
    end

    return world
end

return LevelBuilder
