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
    for _, tag in ipairs(data.__tags) do
        if self.entityTable[tag] then
            local entityGenerator = self.entityTable[tag]
            return entityGenerator(data, level)
        end
    end
    return nil
end

function LevelBuilder:load(filename)
    assert(love.filesystem.getInfo(filename), "Level file " .. filename .. " does not exist")

    local fileData = love.filesystem.read(filename)

    self.data = json.decode(fileData)

    local world = World:new(self.data)

    -- Create sprite batches from tilesets
    for _, tilesetData in ipairs(self.data.defs.tilesets) do
        local tileset = Tileset:new(tilesetData)
        self.tilesets[tileset.id] = tileset
        self.tilesets[tileset.uid] = tileset
    end

    for _, levelData in ipairs(self.data.levels) do
        local level = Level:new(levelData, self)
        world:addLevel(level)
    end

    return world
end

return LevelBuilder
