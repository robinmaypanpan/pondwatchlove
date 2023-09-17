local json = require('json')
local class = require('middleclass')

local Level = class('Level')

function Level:initialize(data)
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

    local bgColor = data.bgColor or data.__bgColor

    self.background = {
        color = bgColor,
    }

    if data.bgRelPath then
        local bgPath = fixRelPath(data.bgRelPath)
        self.background.image = love.graphics.newImage(bgPath)
        self.background.position = data.bgPos
        self.background.pivotX = data.bgPivotX
        self.background.pivotY = data.bgPivotY
    end

    self:load()
end

-- Loads all the data for this level
function Level:load()
    if self.filename then   
        -- TODO: Make this generic  
        local filename = 'assets/levels/' .. self.filename
        assert(love.filesystem.getInfo(filename), "Level file " .. filename .. " does not exist")

        local fileData = love.filesystem.read(filename)

        self.data = json.decode(fileData)
    end

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
function Level:draw(layerDefinition)
end

-- Special function to specifically draw the background
function Level:drawBackground()
end

return Level