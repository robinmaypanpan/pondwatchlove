if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- This is called once on application startup. Techincally not necessary,
-- but it can feel good to use.
function love.load()
    x = 400
    y = 300
end

-- Called before calling draw each time a frame updates
function love.update()
    if love.mouse.isGrabbed and not love.mouse.isDown(1) then
        x, y = love.mouse.getPosition()
    end
end

-- Called after calling update each frame.
function love.draw()
    love.graphics.print("Hello World", x, y)
end
