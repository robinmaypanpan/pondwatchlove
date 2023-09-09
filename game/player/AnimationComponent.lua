local class = require('lib/middleclass')

local AnimationComponent = class('AnimationComponent')

local AnimationSpeed = 12

function AnimationComponent:initialize(player)
    self.player = player

    -- BUG: We shouldn't be drawing the width and height from the image
    self.image = love.graphics.newImage('assets/sprites/birb.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.spritesheet = love.graphics.newImage('assets/sprites/birb_spritesheet.png')
    self.walkQuads = self:getSpritesheetQuads(self.spritesheet, 6, self.width, self.height)
    self.animProgress = 1
    self.animFrame = 1
end

-- takes an image, and using the other variables, creates a table of x,y coords to use
-- for quads in the for loop.
-- currently, this code only works for a 6 cell, horizintal animation
function AnimationComponent:getSpritesheetQuads(image, frameCount, frameWidth, frameHeight)
    local quadData = {}
    local sheetWidth = image:getWidth()
    local sheetHeight = image:getHeight()
    for i = 0, frameCount, 1 do
        quadData[i + 1] = love.graphics.newQuad(frameWidth * i, 0, frameWidth, frameHeight, sheetWidth, sheetHeight)
    end
    return quadData
end

function AnimationComponent:update(updates)
    local dt = love.timer.getDelta()

    if updates.moveLeft or updates.moveRight then
        if self.animProgress >= 7 then
            self.animProgress = 1
        end
        self.animFrame = math.floor(self.animProgress)
        self.animProgress = self.animProgress + dt * AnimationSpeed
    else
        self.animProgress = 1
        self.animFrame = 1
    end
end

-- Draw the player's componetn
function AnimationComponent:draw()
    local scale = 1
    local width = 0
    if self.player.flipImage then
        scale = -1
        width = self.width
    end
    love.graphics.draw(self.spritesheet, self.walkQuads[self.animFrame], self.player.x, self.player.y, 0, scale, 1, width)
end

return AnimationComponent
