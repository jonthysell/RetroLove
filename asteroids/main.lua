-- asteroids\main.lua
-- Copyright (c) 2017 Jon Thysell

require "utils"
require "sprite"

resWidth = 320
resHeight = 240

margin = 20

thrustSpeed = 2
maxThrustMultiplier = 3
rotateSpeed = math.rad(90)

started = false
debugMode = false

screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

function resetRound()
    started = false
end

function resetGame()
    player = {
        score = 0,
        lives = 2,
    }
    
    ship = Ship:new({
        x = resWidth / 2,
        y = resHeight / 2,
        heading = 0,
    })
    
    resetRound()
end

function gameOverCheck()
    if player.lives >= 0 then
        -- Check for remaining asteroids
        -- TODO
        return false
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

function love.load()
    -- Init offscreen graphics
    canvas = love.graphics.newCanvas(resWidth, resHeight)
    canvas:setFilter("nearest", "nearest", 0)
    love.graphics.setFont(love.graphics.newFont(margin * .7))
    
    -- Load sounds
    -- TODO
    
    math.randomseed(os.time())
    resetGame()
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
        if input.left then
            ship.heading = ship.heading + (rotateSpeed * dt)
        elseif input.right then
            ship.heading = ship.heading - (rotateSpeed * dt)
        end
        
        while ship.heading < 0 do ship.heading = ship.heading + 2 * math.pi end
        while ship.heading >= 2 * math.pi do ship.heading = ship.heading - 2 * math.pi end
        
        if input.thrust then
            local newThrust = {
                dx = thrustSpeed * dt * math.cos(ship.heading),
                dy = -1 * thrustSpeed * dt * math.sin(ship.heading),
            }
            ship.mv = vectorAdd(ship.mv, newThrust)
        end
        
        ship.mv.dx = bound(ship.mv.dx, -maxThrustMultiplier * thrustSpeed, maxThrustMultiplier * thrustSpeed)
        ship.mv.dy = bound(ship.mv.dy, -maxThrustMultiplier * thrustSpeed, maxThrustMultiplier * thrustSpeed)
        
        -- Process ship movements
        ship:move(margin, resWidth - margin, margin, resHeight - margin)
        
        -- Process shot movements
        -- TODO
        
        -- Process asteroid movements
        -- TODO
        
        -- Process collisions
        -- TODO
        
        if gameOverCheck() then
            resetGame()
        end
        
    end
end

function drawSprite(s)
    s:draw()
    
    -- Draw mirrored
    if s.x - s.r < margin then s:draw(s.x + (resWidth - 2 * margin)) end
    if s.x + s.r > resWidth - margin then s:draw(s.x - (resWidth - 2 * margin)) end
    if s.y - s.r < margin then s:draw(s.x, s.y + (resHeight - 2 * margin)) end
    if s.y + s.r > resHeight - margin then s:draw(s.x, s.y - (resHeight - 2 * margin)) end
end

function love.draw()
    -- Draw to canvas
    love.graphics.setCanvas(canvas)
    
    love.graphics.clear()
    
    local font = love.graphics.getFont()
    
    love.graphics.setColor({255, 255, 255})
    
    -- Draw ship
    drawSprite(ship)
    
    -- Draw shots
    -- TODO
    
    -- Draw asteroids
    -- TODO
    
    -- Draw margins
    love.graphics.setColor({0, 0, 0})
    love.graphics.rectangle("fill", 0, 0, margin, resHeight - margin)
    love.graphics.rectangle("fill", 0, resHeight - margin, resWidth - margin, resHeight)
    love.graphics.rectangle("fill", margin, 0, resWidth, margin)
    love.graphics.rectangle("fill", resWidth - margin, margin, resWidth, resHeight)
    love.graphics.setColor({255, 255, 255})
    love.graphics.rectangle("line", margin - 1 , margin - 1, resWidth - 2 * (margin - 1), resHeight - (2 * margin - 1))
    
    -- Draw score
    local scoreText = tostring(player.score)
    love.graphics.print(scoreText, (resWidth - font:getWidth(scoreText)) / 2, (margin - font:getHeight(scoreText)) / 2)
    
    -- Draw lives
    local livesText = "x"..tostring(player.lives)
    love.graphics.print(livesText, margin / 4, resHeight - margin + ((margin - font:getHeight(livesText)) / 2))
    
    -- Draw Debug Info
    if debugMode then
       local fpsText = "FPS: "..tostring(love.timer.getFPS())
       love.graphics.print(fpsText, resWidth - (font:getWidth(fpsText) + margin / 4), resHeight - margin + ((margin - font:getHeight(fpsText)) / 2))
       
       local thrustText = tostring(math.floor(math.deg(ship.heading)))..", "..tostring(math.floor(ship.mv.dx))..", "..tostring(math.floor(ship.mv.dy))
       love.graphics.print(thrustText, (resWidth - font:getWidth(thrustText)) / 2, resHeight - margin + ((margin - font:getHeight(thrustText)) / 2))
    end
    
    -- Draw canvas to screen
    love.graphics.setCanvas()
    
    scale = math.min(screenWidth / resWidth, screenHeight / resHeight)
    love.graphics.draw(canvas, (screenWidth - resWidth * scale) / 2, (screenHeight - resHeight * scale) / 2, 0, scale, scale)
end
