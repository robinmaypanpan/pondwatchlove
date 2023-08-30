if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local LevelBuilder = require('src/LevelBuilder')
local builder = LevelBuilder:new()

function love.load()
    world = builder:loadLDTK('assets/levels/test1.ldtk')
end

-- Called before calling draw each time a frame updates
function love.update()
end

-- Called after calling update each frame.
function love.draw()
    if builder.data then
        love.graphics.print('Loaded: ' .. builder.data.levels[1].identifier)
        love.graphics.draw(builder.tilesets['Pixel_platformer_characters'].imageSource)
    end
end
