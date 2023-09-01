local json = require('lib/json')
local class = require('lib/middleclass')

local Level = require('src/Level')
local World = require('src/World')
local Tileset = require('src/Tileset')

local LevelBuilder = class('src/LevelBuilder')

function LevelBuilder:initialize()
    self.tilesets = {}
end

function LevelBuilder:loadLDTK(filename)
    assert(love.filesystem.getInfo(filename), "Level file " .. filename .. " does not exist")

    local fileData = love.filesystem.read(filename)

    self.data = json.decode(fileData)

    local world = World:new(self.data)

    -- Create sprite batches from tilesets
    for _, tilesetData in pairs(self.data.defs.tilesets) do
        local tileset = Tileset:new(tilesetData)
        self.tilesets[tileset.id] = tileset
        self.tilesets[tileset.uid] = tileset
    end

    for _, levelData in pairs(self.data.levels) do
        local level = Level:new(levelData, self)
        world:addLevel(level)
    end

    return world
end

return LevelBuilder
