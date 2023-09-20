local json = require('json')
local class = require('middleclass')

local getFields = require('ldtk2.getFields')

local Tileset = require('ldtk2.Tileset')
local EnumSet = require('ldtk2.EnumSet')
local EntityLayer = require('ldtk2.EntityLayer')
local Level = require('ldtk2.Level')

local Camera = require('ldtk2.Camera')

-- Extracts the settings for the world
local function configureWorld(world, data)
    -- Store a raw copy of the data
    world.data = data

    -- The grid size when dealing with a grid vania
    world.gridWidth = data.worldGridWidth
    world.gridHeight = data.worldGridHeight

    -- Store arbitrary fields
    world.fields = getFields(data)
end

-- Returns a list of tileset objects configured with provided data
local function extractTilesets(data)
    local tilesets = {}
    for _, tilesetData in ipairs(data) do
        if tilesetData.relPath then
            local tileset = Tileset:new(tilesetData)
            tileset:load()
            tilesets[tileset.id] = tileset
            tilesets[tileset.uid] = tileset
        end
    end
    return tilesets
end

-- Returns a list of enums
local function extractEnums(data, tilesets)
    local enumSets = {}
    for _, enumSetData in ipairs(data) do
        local enumSet = EnumSet:new(enumSetData, tilesets)

        enumSets[enumSet.id] = enumSet
        enumSets[enumSet.uid] = enumSet
    end
end

-- Extract and create all the layers that need to be rendered
local function extractLayerDefinitions(data)
    local layerList = {}
    local layerDb = {}
    for i = #data, 1, -1 do
        local layerDefinition = data[i]
        table.insert(layerList, layerDefinition)
        layerDb[layerDefinition.identifier] = layerDefinition
    end

    return layerDb, layerList
end

-- Returns a table of levels
local function extractLevels(data, layers, tilesets)
    local levelDb = {}
    local levelList = {}

    for _, levelData in ipairs(data) do
        local level = Level:new(levelData, layers, tilesets)
        levelDb[level.uid] = level
        levelDb[level.iid] = level
        levelDb[level.id] = level
        table.insert(levelList, level)
    end

    return levelDb, levelList
end

-- Represents a single LDTK world
local World = class('World')

function World:initialize()
    -- Active levels should be drawn and updated
    self.activeLevels = {}

    self.camera = Camera:new(self)
end

-- Configure the game
function World:configure(options)
    self.options = options
    if options.entityTable then
        self.entityTable = options.entityTable
    end

    if options.cameraSettings then
        self.camera = Camera:new(self, options.cameraSettings)
    end
end

function World:configureCamera(options)
    self.camera = Camera:new(self, options)
end

-- Loads the world from an ldtk file
function World:loadFromFile(filename)
    assert(love.filesystem.getInfo(filename), "Level file " .. filename .. " does not exist")

    local rawData = love.filesystem.read(filename)

    local data = json.decode(rawData)

    configureWorld(self, data)

    self.tilesetDb = extractTilesets(data.defs.tilesets)
    self.enums = extractEnums(data.defs.enums, self.tilesetDb)
    self.layerDb, self.layerList = extractLayerDefinitions(data.defs.layers)
    self.levelDb, self.allLevels = extractLevels(data.levels, self.layerDb, self.tilesetDb)

    if self.options.activateAllLevels then
        local levels = {}
        for _, level in ipairs(self.allLevels) do
            table.insert(levels, level.id)
        end
        self:setActiveLevels(levels)
    end
end

-- Returns a level at a given location, checking active levels first
function World:getLevelAt(x, y)
    for _, level in ipairs(self.levelList) do
        if level:isWithinLevel(x, y) then
            return level
        end
    end

    return nil
end

-- Prepares a transition from the current level to the provided level id
function World:prepareLevelTransitionTo(levelId)
    self.newLevel = self.levelDb[levelId]
    assert(self.newLevel ~= nil, 'Invalid level id provided')

    -- update the current level property
    local oldLevel = self.currentLevel

    -- Set both levels to active
    self:setActiveLevels({ self.newLevel.id, oldLevel.id })

    -- Allow the camera to move freely
    self.camera:unlockCamera()
end

-- Completes an in progress level transition
function World:completeLevelTransition()
    assert(self.newLevel ~= nil, 'Not currently transitioning levels')
    self.currentLevel = self.newLevel
    self.newLevel = nil
    self:setCurrentLevel(self.currentLevel.id)
end

-- Sets the provided level as active and locks the camera to it
function World:setCurrentLevel(levelId)
    local newLevel = self.levelDb[levelId]
    self.currentLevel = newLevel

    self:setActiveLevels({ levelId })
    self.camera:lockCamera(newLevel)
end

-- returns the current level
function World:getCurrentLevel()
    return self.currentLevel
end

-- Sets the active levels to draw and nearby levels to
-- update
function World:setActiveLevels(levelList)
    -- First, cache a map of levels that are activated already
    local activeLevels = {}
    for _, levelId in ipairs(levelList) do
        activeLevels[levelId] = true
    end

    -- Deactive old levels that are not in the list
    for _, level in ipairs(self.activeLevels) do
        if not activeLevels[level.id] then
            level:deactivate()
        end
    end

    -- Now setup the newly active levels
    self.activeLevels = {}
    for _, levelId in ipairs(levelList) do
        -- first load all the level data
        local level = self.levelDb[levelId]
        assert(level ~= nil, 'Could not find desired level')
        table.insert(self.activeLevels, level)
        level:activate()
    end
end

-- Returns the camera
function World:getCamera()
    return self.camera
end

-- Executes any updates in the world and makes sure updates
-- are sent to all children
function World:update(dt)
    self.camera:update(dt)
    for _, level in ipairs(self.activeLevels) do
        level:update(dt)
    end
end

-- Draws the world
function World:draw()
    self.camera:attach()
    -- Draw backgrounds for all the currently active levels
    for _, level in ipairs(self.activeLevels) do
        level:drawBackground()
    end

    -- Iterate over each layer
    for _, layerDefinition in ipairs(self.layerList) do
        for _, level in ipairs(self.activeLevels) do
            level:drawLayer(layerDefinition)
        end
    end
    self.camera:detach()
end

return World
