-- breakout\main.lua
-- Copyright (c) 2017 Jon Thysell

resWidth = 320
resHeight = 240

margin = 20

paddleSpeed = 2
ballSpeed = 0.5

paddleBounce = 1.1

numRowsOfBlocks = 4
numBlocksPerRow = 10

started = false
debugMode = false

screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

function resetRound()
    paddle.x = (resWidth - paddleWidth) / 2
    paddle.y = resHeight - paddleHeight - ballSize - margin
    
    ball = {
        x = (resWidth - ballSize) / 2,
        y = paddle.y - 3 * ballSize,
        dx = 0.5 + 0.1 * math.random(),
        dy = -1 * (0.5 + 0.1 * math.random())
    }

    if math.random() > 0.5 then ball.dx = -ball.dx end
    
    started = false
end

function resetGame()
    paddleHeight = resHeight * 0.015
    paddleWidth = resWidth * 0.15
    
    ballSize = paddleHeight
    
    blockHeight = paddleHeight * 2
    blockWidth = (resWidth - 2 * margin) / numBlocksPerRow
    
    paddle = {
        moving = false,
        lives = 2,
        score = 0,
    }
    
    blocks = {}
    for row = 1, numRowsOfBlocks do
        blocks[row] = {}
        for col = 1, numBlocksPerRow do
            blocks[row][col] = true
        end
    end
    
    resetRound()
end

function gameOverCheck()
    if paddle.lives >= 0 then
        for row = 1, numRowsOfBlocks do
            for col = 1, numBlocksPerRow do
                if blocks[row][col] then return false end
            end
        end
    end
    
    return true
end

function getInput()
    if love.keyboard.isDown("left") then
        return "left"
    elseif love.keyboard.isDown("right") then
        return "right"
    end
    
    if love.touch then
        local touches = love.touch.getTouches()
        for i, id in ipairs(touches) do
            local x, y = love.touch.getPosition(id)
            if x <= screenWidth * .4 then
                return "left"
            elseif x >= screenWidth * .6 then
                return "right"
            end
        end
    end
    
    return nil
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
    math.randomseed(os.time())
    resetGame()
    
    -- Init offscreen graphics
    canvas = love.graphics.newCanvas(resWidth, resHeight)
    
    -- Init sounds
    bounceSFX = love.audio.newSource("bounce.ogg", "static")
    hitSFX = love.audio.newSource("hit.ogg", "static")
end

function love.resize()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.update(dt)
    input = getInput()
    
    if not started then
        if input then
            started = true
        end
    else
        -- Process input for paddle
        if input == "left" then
            paddle.x = paddle.x - (paddleWidth * paddleSpeed * dt)
            paddle.moving = true
        elseif input == "right" then
            paddle.x = paddle.x + (paddleWidth * paddleSpeed * dt)
            paddle.moving = true
        else
            paddle.moving = false
        end
        
        -- Process paddle bounds
        paddle.x = math.max(paddle.x, margin)
        paddle.x = math.min(paddle.x, resWidth - paddleWidth - margin)
        
        -- Process ball movement
        ball.dx = math.min(1, math.max(ball.dx, -1))
        ball.dy = math.min(1, math.max(ball.dy, -1))
        
        ball.x = ball.x + (ball.dx * ballSpeed * math.min(resHeight, resWidth) * dt)
        ball.y = ball.y + (ball.dy * ballSpeed * math.min(resHeight, resWidth) * dt)
        
        -- Process wall/ball collisions
        if ball.x < margin then
            love.audio.play(bounceSFX)
            ball.x = margin
            ball.dx = -ball.dx
        elseif ball.x > resWidth - ballSize - margin then
            love.audio.play(bounceSFX)
            ball.x = resWidth - ballSize - margin
            ball.dx = -ball.dx
        end
        
        -- Process block collisions
        local blockHit = 0
        for row = 1, numRowsOfBlocks do
            for col = 1, numBlocksPerRow do
                if blocks[row][col] then
                    local x, y = margin + (col - 1) * blockWidth, margin + (numRowsOfBlocks - row + 1) * blockHeight
                    if ball.x + ballSize > x and ball.x < x + blockWidth and ball.y + ballSize > y and ball.y < y + blockHeight then
                        blocks[row][col] = false
                        blockHit = row
                        
                        -- Bounce the ball apropriately
                        
                        break
                    end
                end
            end
            if blockHit > 0 then break end
        end
        
        if blockHit > 0 then
            love.audio.play(hitSFX)
            paddle.score = paddle.score + blockHit
        end
        
        -- Process paddle collisions
        if ball.y < margin then
            love.audio.play(bounceSFX)
            ball.y = margin
            ball.dy = -ball.dy
        elseif ball.y + ballSize > paddle.y then
            -- ball is crossing into bottom
            if ball.x + ballSize > paddle.x and ball.x < paddle.x + paddleWidth then
                -- paddle hits ball
                love.audio.play(hitSFX)
                ball.y = paddle.y - ballSize
                ball.dy = -ball.dy
                if paddle.moving then
                    ball.dx = ball.dx * paddleBounce
                    ball.dy = ball.dy * paddleBounce
                end
            elseif ball.y >= resHeight - margin then
                -- paddle misses ball
                paddle.lives = paddle.lives - 1
                resetRound()
            end
        end
        
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
    love.graphics.rectangle("line", margin, margin, resWidth - 2 * margin, resHeight - 2 * margin);

    local font = love.graphics.getFont()
    
    -- Draw score
    local scoreText = "Score: "..tostring(paddle.score)
    love.graphics.print(scoreText, (resWidth - font:getWidth(scoreText)) / 2, ballSize / 2)
    
    -- Draw lives
    local livesText = "x"..tostring(paddle.lives)
    love.graphics.print(livesText, margin / 4, resHeight - margin + ((margin - font:getHeight(livesText)) / 2))
    
    -- Draw paddle
    love.graphics.rectangle("fill", paddle.x, paddle.y, paddleWidth, paddleHeight)
    
    -- Draw ball
    love.graphics.circle("fill", ball.x + (ballSize / 2), ball.y + (ballSize / 2), ballSize / 2)
    
    -- Draw blocks
    for row = 1, numRowsOfBlocks do
        for col = 1, numBlocksPerRow do
            if blocks[row][col] then
                local x, y = margin + (col - 1) * blockWidth, margin + (numRowsOfBlocks - row + 1) * blockHeight
                love.graphics.rectangle("fill", x, y, blockWidth, blockHeight)
            end
        end
    end
    
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