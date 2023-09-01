local json = require('lib/json')
local class = require('lib/middleclass')

local Level = require('lib/ldtk/Level')
local World = require('lib/ldtk/World')
local Tileset = require('lib/ldtk/Tileset')

local LevelBuilder = class('LevelBuilder')

function LevelBuilder:initialize()
    self.tilesets = {}
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
