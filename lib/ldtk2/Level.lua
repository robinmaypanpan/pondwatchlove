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

return Level