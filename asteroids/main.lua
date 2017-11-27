-- asteroids\main.lua
-- Copyright (c) 2017 Jon Thysell

require "utils"
require "sprite"
require "queue"

resWidth = 320
resHeight = 240

margin = 20

highScore = 0
startingLives = 2
startingShieldTime = 3
startingStage = 0

extraLivesScoreThreshold = 1000

shipThrustSpeed = 2
maxShipSpeed = 200
shipRotateSpeed = math.rad(90)

shotSpeed = 200
maxShots = 5
shotCooldownTime = 1 / maxShots

startingAsteroidsMin = 2
startingAsteroidsMax = 8

startingAsteroidMaxSpeed = 25
explodeSpeedMultiplier = 10/9
asteroidValue = 64

debugMode = false

screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

function resetShip()
    ship = Ship:new({
        x = resWidth / 2,
        y = resHeight / 2,
        heading = math.rad(90),
        shieldTimeRemaining = startingShieldTime,
    })
    
    shots = Queue:new()
    timeSinceLastShot = 0
end

function resetStage()
    local stage = player.stage
    
    local numAsteroids = math.min(startingAsteroidsMin + stage, startingAsteroidsMax)
    
    asteroids = Queue:new()
    for i = 1, numAsteroids do
        local asteroid = Asteroid:new({
            x = margin + (resWidth - 2 * margin) * math.random(),
            y = margin + (resHeight - 2 * margin) * math.random(),
            orientation = math.rad(math.random(0, 360)),
            dx = -startingAsteroidMaxSpeed + (2 * startingAsteroidMaxSpeed) * math.random(),
            dy = -startingAsteroidMaxSpeed + (2 * startingAsteroidMaxSpeed) * math.random(),
        })
        asteroids:enqueue(asteroid)
    end
end

function resetGame()
    player = {
        score = 0,
        lives = startingLives,
        stage = startingStage
    }
    
    resetStage()
    resetShip()
    
    pauseState = "GAME OVER"
end

function getInput()
    local input = {
        left = false,
        right = false,
        thrust = false,
        fire = false,
        start = false,
    }
    
    if ship.isAlive then        
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
    end
    
    return input
end

function love.load()
    -- Init offscreen graphics
    canvas = love.graphics.newCanvas(resWidth, resHeight)
    canvas:setFilter("nearest", "nearest", 0)
    love.graphics.setFont(love.graphics.newFont(margin * .7))
    
    -- Load sounds
    sfx = {}
    sfx.shot = love.audio.newSource("shot.ogg", "static")
    sfx.hit = love.audio.newSource("hit.ogg", "static")
    sfx.death = love.audio.newSource("death.ogg", "static")
    sfx.extralife = love.audio.newSource("extralife.ogg", "static")
    
    math.randomseed(os.time())
    resetGame()
end

function love.keyreleased(key)
    if key == "q" or key == "escape" then
        love.event.quit()
    elseif key == "return" then
        if pauseState then
            pauseState = nil
        else
            pauseState = "PAUSED"
        end
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

function mirroredCollision(s1, s2)
    -- Check for regular collision
    if collision(s1, s2) then return true end
    
    local m1 = s1:getMirrors(margin, resWidth - margin, margin, resHeight - margin)
    table.insert(m1, { x = s1.x, y = s1.y })
    local r1 = s1.r
    
    local m2 = s2:getMirrors(margin, resWidth - margin, margin, resHeight - margin)
    table.insert(m2, { x = s2.x, y = s2.y })
    local r2 = s2.r
    
    for i = 1, #m1 do
        for j = 1, #m2 do
            if collision({ x = m1[i].x, y = m1[i].y, r = r1 }, { x = m2[j].x, y = m2[j].y, r = r2}) then return true end
        end
    end
    
    return false
end

function love.update(dt)
    local input = getInput()
    
    if not pauseState then
        -- Process input
        if input.left then
            ship.heading = ship.heading + (shipRotateSpeed * dt)
        elseif input.right then
            ship.heading = ship.heading - (shipRotateSpeed * dt)
        end
        
        while ship.heading < 0 do ship.heading = ship.heading + 2 * math.pi end
        while ship.heading >= 2 * math.pi do ship.heading = ship.heading - 2 * math.pi end
        
        if input.thrust then
            local newThrust = {
                dx = shipThrustSpeed * math.cos(ship.heading),
                dy = -1 * shipThrustSpeed * math.sin(ship.heading),
            }
            newThrust = vectorAdd(newThrust, {dx = ship.dx, dy = ship.dy})
            ship.dx, ship.dy = newThrust.dx, newThrust.dy
        end
        
        timeSinceLastShot = timeSinceLastShot + dt
        
        if input.fire then
            if shots:count() < maxShots and timeSinceLastShot >= shotCooldownTime then
                love.audio.play(sfx.shot)
                local newShot = Shot:new({
                    x = ship.x + ship.r * math.cos(ship.heading),
                    y = ship.y - ship.r * math.sin(ship.heading),
                    dx = ship.dx + shotSpeed * math.cos(ship.heading),
                    dy = ship.dy + (-1 * shotSpeed * math.sin(ship.heading)),
                    timeRemaining = 2 * shotCooldownTime,
                })
                newShot.timeRemaining = newShot.timeRemaining + dt
                shots:enqueue(newShot)
                timeSinceLastShot = 0
            end
        end
        
        -- Bound and process ship movement
        ship.dx = bound(ship.dx, -maxShipSpeed, maxShipSpeed)
        ship.dy = bound(ship.dy, -maxShipSpeed, maxShipSpeed)
        
        if ship.isAlive then
            ship:move(dt, margin, resWidth - margin, margin, resHeight - margin)
        end
        
        -- Process shot movements
        for i = 1, shots:count() do
            local shot = shots:dequeue()
            shot.timeRemaining = shot.timeRemaining - dt
            if shot.timeRemaining > 0 then
                shot:move(dt, margin, resWidth - margin, margin, resHeight - margin)
                shots:enqueue(shot)
            end
        end
        
        -- Process asteroid movements
        for i = 1, asteroids:count() do
            local asteroid = asteroids:dequeue()
            asteroid:move(dt, margin, resWidth - margin, margin, resHeight - margin)
            asteroids:enqueue(asteroid)
        end
        
        -- Process shot/asteroid collisions
        for i = 1, shots:count() do
            local shot = shots:dequeue()
            local hit = false
            
            for j = 1, asteroids:count() do
                local asteroid = asteroids:dequeue()
                hit = hit or mirroredCollision(shot, asteroid)
                if hit then
                    love.audio.play(sfx.hit)
                    local beforeScore = player.score
                    player.score = player.score + asteroidValue / asteroid.r
                    highScore = math.max(highScore, player.score)
                    local afterScore = player.score
                    
                    if passThreshold(beforeScore, afterScore, extraLivesScoreThreshold) then
                        -- Extra life
                        love.audio.play(sfx.extralife)
                        player.lives = player.lives + 1
                    end
                    
                    local a1, a2 = asteroid:split(explodeSpeedMultiplier)
                    if a1.r > 2 then asteroids:enqueue(a1) end
                    if a2.r > 2 then asteroids:enqueue(a2) end
                    
                    break
                end
                asteroids:enqueue(asteroid)
            end
            
            if not hit then shots:enqueue(shot) end
        end
        
        -- Process ship/asteroid collisions
        if ship.isAlive and ship.shieldTimeRemaining <= 0 then
            -- Ship can be hit
            for i = 1, asteroids:count() do
                local asteroid = asteroids:dequeue()
                local shipHit = mirroredCollision(ship, asteroid)
                asteroids:enqueue(asteroid)
                if shipHit then
                    love.audio.play(sfx.death)
                    ship.deathTimeRemaining = 1.0
                    ship.isAlive = false
                    player.lives = player.lives - 1
                    break
                end
            end
        elseif ship.isAlive and ship.shieldTimeRemaining > 0 then
            ship.shieldTimeRemaining = ship.shieldTimeRemaining - dt
        elseif not ship.isAlive then
            ship.deathTimeRemaining = ship.deathTimeRemaining - dt
        end
        
        -- Gameover check
        if ship.isAlive and asteroids:count() == 0 then
            -- Load next stage
            player.stage = player.stage + 1
            resetStage()
            resetShip()
        elseif not ship.isAlive and ship.deathTimeRemaining <= 0 then
            -- Ship has finished dying
            if player.lives >= 0 then
                resetShip()
            elseif player.lives < 0 then
                resetGame()
            end
        end
    end
end

function drawMirroredSprite(s)
    -- Draw main sprite
    s:draw()
    
    -- Draw mirrors
    local mirrors = s:getMirrors(margin, resWidth - margin, margin, resHeight - margin)
    for i = 1, #mirrors do
        s:draw(mirrors[i].x, mirrors[i].y)
    end
end

function love.draw()
    -- Draw to canvas
    love.graphics.setCanvas(canvas)
    
    love.graphics.clear()
    
    local font = love.graphics.getFont()
    
    love.graphics.setColor({255, 255, 255})
    
    if pauseState then
        local centerText = tostring(pauseState)
        love.graphics.print(centerText, (resWidth - font:getWidth(centerText)) / 2, (resHeight - font:getHeight(centerText)) / 2)
    else
        -- Draw ship
        drawMirroredSprite(ship)

        -- Draw shots
        for i = 1, shots:count() do
            local shot = shots:dequeue()
            drawMirroredSprite(shot)
            shots:enqueue(shot)
        end

        -- Draw asteroids
        for i = 1, asteroids:count() do
            local asteroid = asteroids:dequeue()
            drawMirroredSprite(asteroid)
            asteroids:enqueue(asteroid)
        end
    end
    
    -- Draw margins
    love.graphics.setColor({0, 0, 0})
    love.graphics.rectangle("fill", 0, 0, margin, resHeight - margin)
    love.graphics.rectangle("fill", 0, resHeight - margin, resWidth - margin, resHeight)
    love.graphics.rectangle("fill", margin, 0, resWidth, margin)
    love.graphics.rectangle("fill", resWidth - margin, margin, resWidth, resHeight)
    love.graphics.setColor({255, 255, 255})
    love.graphics.rectangle("line", margin - 1 , margin - 1, resWidth - 2 * (margin - 1), resHeight - (2 * margin - 1))
    
    -- Draw score
    local scoreText = "SCORE: "..tostring(player.score)
    if pauseState == "GAME OVER" then scoreText = "HI-SCORE: "..tostring(highScore) end
    love.graphics.print(scoreText, (resWidth - font:getWidth(scoreText)) / 2, (margin - font:getHeight(scoreText)) / 2)
    
    -- Draw lives
    local livesText = "x"..tostring(math.max(0, player.lives))
    love.graphics.print(livesText, margin / 4, resHeight - margin + ((margin - font:getHeight(livesText)) / 2))
    
    -- Draw Debug Info
    if debugMode then
       local fpsText = "FPS: "..tostring(love.timer.getFPS())
       love.graphics.print(fpsText, resWidth - (font:getWidth(fpsText) + margin / 4), resHeight - margin + ((margin - font:getHeight(fpsText)) / 2))
       
       local thrustText = tostring(math.floor(math.deg(ship.heading)))..", "..tostring(math.floor(ship.dx))..", "..tostring(math.floor(ship.dy))
       love.graphics.print(thrustText, (resWidth - font:getWidth(thrustText)) / 2, resHeight - margin + ((margin - font:getHeight(thrustText)) / 2))
    end
    
    -- Draw canvas to screen
    love.graphics.setCanvas()
    
    scale = math.min(screenWidth / resWidth, screenHeight / resHeight)
    love.graphics.draw(canvas, (screenWidth - resWidth * scale) / 2, (screenHeight - resHeight * scale) / 2, 0, scale, scale)
end
