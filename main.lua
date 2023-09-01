if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local LevelBuilder = require('src/LevelBuilder')
local builder = LevelBuilder:new()

function love.load()
    world = builder:loadLDTK('assets/levels/test1.ldtk')
    world:displayLevel('Entrance')
end

-- Called before calling draw each time a frame updates
function love.update()
end

-- Called after calling update each frame.
function love.draw()
    world:draw()
end
