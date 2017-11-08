-- asteroids\main.lua
-- Copyright (c) 2017 Jon Thysell

resWidth = 320
resHeight = 240

margin = 20

started = false
debugMode = false

screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

function resetRound()
    
    started = false
end

function resetGame()
    ship = {
        x = 0,
        y = 0,
        heading = 0,
        score = 0,
        lives = 2,
    }
    resetRound()
end

function gameOverCheck()
    if ship.lives >= 0 then
        -- Check for remaining asteroids
        -- TODO
    end
    
    return true
end

function getInput()
    local input = {
        left = false,
        right = false,
        thrust = false,
        fire = false,
    }
    
    -- Process Keyboard
    if love.keyboard.isDown("left") then input.left = true end
    if love.keyboard.isDown("right") then input.right = true end
    if love.keyboard.isDown("up") then input.thrust = true end
    if love.keyboard.isDown("space") then input.fire = true end
    
    -- Process Touch
    if love.touch then
        local touches = love.touch.getTouches()
        for i, id in ipairs(touches) do
            local x, y = love.touch.getPosition(id)
            -- TODO
        end
    end
    
    return input
end

function love.keyreleased(key)
    if key == "q" or key == "escape" then
        love.event.quit()
    elseif key == "d" then
        debugMode = not debugMode
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if x > screenWidth * .4 and x < screenWidth * .6 then
        if y > screenHeight / 2 then
            love.event.quit()
        else
            debugMode = not debugMode
        end
    end
end

function love.load()
    -- Init offscreen graphics
    canvas = love.graphics.newCanvas(resWidth, resHeight)
    canvas:setFilter("nearest", "nearest", 0)
    love.graphics.setFont(love.graphics.newFont(margin * .7))
    
    -- Load sprites
    -- TODO
    
    -- Load sounds
    -- TODO
    
    math.randomseed(os.time())
    resetGame()
end

function love.resize()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.update(dt)
    local input = getInput()
    
    if not started then
        if input.fire then
            started = true
        end
    else
        -- Process input
        -- TODO
        
        -- Process sprite movements
        -- TODO
        
        -- Process sprite collisions
        -- TODO
        
        if gameOverCheck() then
            resetGame()
        end
        
    end
end

function love.draw()
    -- Draw to canvas
    love.graphics.setCanvas(canvas)
    
    love.graphics.clear()
    
    -- Draw border
    love.graphics.rectangle("line", margin - 1 , margin - 1, resWidth - 2 * (margin - 1), resHeight - (2 * margin - 1))

    local font = love.graphics.getFont()
    
    -- Draw score
    local scoreText = tostring(ship.score)
    love.graphics.print(scoreText, (resWidth - font:getWidth(scoreText)) / 2, (margin - font:getHeight(scoreText)) / 2)
    
    -- Draw lives
    local livesText = "x"..tostring(ship.lives)
    love.graphics.print(livesText, margin / 4, resHeight - margin + ((margin - font:getHeight(livesText)) / 2))
    
    -- Draw sprites
    -- TODO
    
    -- Draw Debug Info
    if debugMode then
        local fpsText = "FPS: "..tostring(love.timer.getFPS())
       love.graphics.print(fpsText, resWidth - (font:getWidth(fpsText) + margin / 4), resHeight - margin + ((margin - font:getHeight(fpsText)) / 2))
    end
    
    -- Draw canvas to screen
    love.graphics.setCanvas()
    
    scale = math.min(screenWidth / resWidth, screenHeight / resHeight)
    love.graphics.draw(canvas, (screenWidth - resWidth * scale) / 2, (screenHeight - resHeight * scale) / 2, 0, scale, scale)
end
