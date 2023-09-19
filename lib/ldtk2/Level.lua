local json = require('json')
local class = require('middleclass')

local fixRelPath = require('ldtk2.fixRelPath')

local EntityLayer = require('ldtk2.EntityLayer')
local IntLayer = require('ldtk2.IntLayer')
local TileLayer = require('ldtk2.TileLayer')

-- Returns the background table
local function extractBackground(data)
    local background = {}

    background.color = data.bgColor or data.__bgColor;

    if data.bgRelPath then
        local bgPath = fixRelPath(data.bgRelPath)
        background.image = love.graphics.newImage(bgPath)
        background.position = data.bgPos
        background.pivotX = data.bgPivotX
        background.pivotY = data.bgPivotY
    end

    return background
end

-- Returns displayable layers
local function extractLayers(data, level, tilesets)
    local layers = {}
    for _, layerData in ipairs(data.layerInstances) do
        local layer
        if layerData.__type == 'IntGrid' then
            layer = IntLayer:new(layerData, level, tilesets)
        elseif layerData.__type == 'Tiles' or layerData.__type == 'AutoLayer' then
            layer = TileLayer:new(layerData, level, tilesets)
        elseif layerData.__type == 'Entities' then
            layer = EntityLayer:new(layerData, level)
        end

        -- Update our layer database for later access
        layers[layer.id] = layer
    end

    return layers
end

local Level = class('Level')

function Level:initialize(data, tilesets)
    self.data = data
    
    self.id = data.identifier
    self.uid = data.uid
    self.iid = data.iid

    self.filename = data.externalRelPath
    self.isLoaded = false

    self.neighbors = data.__neighbours

    -- X,y position of this level
    self.x = data.worldX
    self.y = data.worldY
    self.width = data.pxWid
    self.height = data.pxHei

    -- Unused at this time
    self.depth = data.worldDepth

    self.fields = getFields(data)

    self.layers = {}
    self.background = {}

    self:load(tilesets)
end

-- Loads all the data for this level
function Level:load(tilesets)
    if self.filename then   
        -- TODO: Make this generic  
        local filename = 'assets/levels/' .. self.filename
        assert(love.filesystem.getInfo(filename), "Level file " .. filename .. " does not exist")

        local fileData = love.filesystem.read(filename)

        self.data = json.decode(fileData)
    end

    self.background = extractBackground(self.data)

    self.layers = extractLayers(self.data, self, tilesets)

    self.isLoaded = true
end

-- returns true if the world x and y coordinates provided are within this level
function Level:isWithinLevel(x, y)
    return x >= self.x and y >= self.y
        and x < self.x + self.width
        and y < self.y + self.height
end

-- Converts world-relative x,y coordinates to level-relative x,y coordinates
function Level:convertWorldToLevel(x, y)
    return x - self.x, y - self.y
end

-- Converts level-relative x,y coordinates to world-relative x,y coordinates
function Level:convertLevelToWorld(x, y)
    return x + self.x, y + self.y
end

-- Returns the layer with the indicated id
function Level:getLayer(layerId)
    return self.layers[layerId]
end

-- Start any operations that should occur while this level is active
function Level:activate()
end

-- Remove any operations that should not occur while this ievel is inactive
function Level:deactivate()
end

-- Used to update the contents of all layers
function Level:update(dt)
end

-- Called to tell the level to draw this indicated layer
function Level:drawLayer(layerDefinition)
    assert(layerDefinition ~= nil, "No layer definition provided to draw layer")
    local layer = self:getLayer(layerDefinition.id)
    assert(layer ~= nil, "Could not find layer " .. layerDefinition.id)

    layer:draw()
end

-- Special function to specifically draw the background
function Level:drawBackground()
end

return Level