-- asteroids\main.lua
-- Copyright (c) 2017 Jon Thysell

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

function vectorAdd(v1, v2)
    return {
        dx = v1.dx + v2.dx,
        dy = v1.dy + v2.dy,
    }
end

function bound(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function resetRound()
    
    started = false
end

function resetGame()
    ship = {
        x = resWidth / 2,
        y = resHeight / 2,
        heading = 0,
        mv = { dx = 0, dy = 0 },
        score = 0,
        lives = 2,
    }
    resetRound()
end

function gameOverCheck()
    if ship.lives >= 0 then
        -- Check for remaining asteroids
        -- TODO
        return false
    end
    
    return true
end

function updateInput()
    input = {
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
    updateInput()
    
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
        ship.x = ship.x + ship.mv.dx
        ship.y = ship.y + ship.mv.dy
        
        -- Process ship wrap around
        while ship.x < margin do ship.x = ship.x + (resWidth - 2 * margin) end
        while ship.x >= resWidth - margin do ship.x = ship.x - (resWidth - 2 * margin) end
        while ship.y < margin do ship.y = ship.y + (resHeight - 2 * margin) end
        while ship.y >= resHeight - margin do ship.y = ship.y - (resHeight - 2 * margin) end
        
        -- Process asteroid movements
        -- TODO
        
        -- Process collisions
        -- TODO
        
        if gameOverCheck() then
            resetGame()
        end
        
    end
end

function getShipPolygon()
    local p = {
        6, 0,
        -6, -4,
        -4, 0,
        -6, 4,
    }
    
    for i = 1, #p, 2 do
        local x, y = p[i], p[i+1]
        p[i] = ship.x + (x * math.cos(ship.heading)) - (y * math.sin(ship.heading))
        p[i+1] = ship.y - ((x * math.sin(ship.heading)) + (y * math.cos(ship.heading)))
    end
    
    return p
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
    
    -- Draw ship
    love.graphics.polygon("fill", getShipPolygon())
    
    -- Draw shots
    -- TODO
    
    -- Draw asteroids
    -- TODO
    
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
