-- breakout\main.lua
-- Copyright (c) 2017 Jon Thysell

resWidth = 320
resHeight = 240

margin = 20

highScore = 0

paddleSpeed = 2
ballSpeed = 0.5

minPaddleBounce = 1.0
maxPaddleBounce = 1.1

numBlocksPerRow = 10

blockColors = {
    {148, 0, 211}, -- violet
    {75, 0, 130}, -- indigo
    {0, 0, 255}, -- blue
    {0, 255, 0}, -- green
    {255, 255, 0}, -- yellow
    {255, 127, 0}, -- orange
    {255, 0, 0}, -- red
}

minNumRowsOfBlocks = 1
maxNumRowsOfBlocks = #blockColors

debugMode = false

screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

function resetPaddle()
    paddle.x = (resWidth - paddleWidth) / 2
    paddle.y = resHeight - paddleHeight - ballSize - margin
    
    ball = {
        x = (resWidth - ballSize) / 2,
        y = paddle.y - 3 * ballSize,
        dx = 0.5 + 0.1 * love.math.random(),
        dy = -1 * (0.5 + 0.1 * love.math.random())
    }

    if love.math.random() > 0.5 then ball.dx = -ball.dx end
    
    started = false
end

function resetStage()
    local stage = paddle.stage
    
    numRowsOfBlocks = math.min(minNumRowsOfBlocks + stage, maxNumRowsOfBlocks)
    
    blocks = {}
    for row = 1, numRowsOfBlocks do
        blocks[row] = {}
        for col = 1, numBlocksPerRow do
            blocks[row][col] = true
        end
    end
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
        stage = 0,
    }
    
    resetPaddle()
    resetStage()
    
    pauseState = "GAME OVER"
    newGame = true
end

function ballHitsBlock(row, col)
    local x, y = margin + (col - 1) * blockWidth, margin + (numRowsOfBlocks - row + 1) * blockHeight
    
    -- Find intersection
    local ix1 = math.max(ball.x, x)
    local iy1 = math.max(ball.y, y)
    local ix2 = math.min(ball.x + ballSize, x + blockWidth)
    local iy2 = math.min(ball.y + ballSize, y + blockHeight)
    
    local hit = false
    
    if ix1 < ix2 and iy1 < iy2 then
        -- Valid intersection
        if ix1 > ball.x then
            -- ball hit left
            ball.x = x - ballSize
            ball.dx = -ball.dx
            hit = true
        elseif ix2 < ball.x + ballSize then
            -- ball hit right
            ball.x = x + blockWidth
            ball.dx = -ball.dx
            hit = true
        end
        
        if iy1 > ball.y then
            -- ball hit top
            ball.y = y - ballSize
            ball.dy = -ball.dy
            hit = true
        elseif iy2 < ball.y + ballSize then
            -- ball hit bottom
            ball.y = y + blockHeight
            ball.dy = -ball.dy
            hit = true
        end
    end
    
    return hit
end

function remainingBlocks()
    local sum = 0
    for row = 1, numRowsOfBlocks do
        for col = 1, numBlocksPerRow do
            if blocks[row][col] then sum = sum + 1 end
        end
    end
    
    return sum
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
        if y < screenHeight / 2 then
            if pauseState then
                pauseState = nil
            else
                pauseState = "PAUSED"
            end
        else
            debugMode = not debugMode
        end
    end
end

function love.load()
    resetGame()
    
    -- Init offscreen graphics
    canvas = love.graphics.newCanvas(resWidth, resHeight)
    canvas:setFilter("nearest", "nearest", 0)
    love.graphics.setFont(love.graphics.newFont(margin * .7))
    
    -- Init sounds
    startSFX = love.audio.newSource("start.ogg", "static")
    bounceSFX = love.audio.newSource("bounce.ogg", "static")
    hitSFX = love.audio.newSource("hit.ogg", "static")
end

function love.resize()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.update(dt)
    local input = getInput()
    
    if not pauseState then
        if newGame then
            love.audio.play(startSFX)
            newGame = false
        end
        
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
                love.audio.play(bounceSFX:clone())
                ball.x = margin
                ball.dx = -ball.dx
            elseif ball.x > resWidth - ballSize - margin then
                love.audio.play(bounceSFX:clone())
                ball.x = resWidth - ballSize - margin
                ball.dx = -ball.dx
            end
            
            -- Process block collisions
            local blockHit = 0
            for row = 1, numRowsOfBlocks do
                for col = 1, numBlocksPerRow do
                    if blocks[row][col] then
                        local hit = ballHitsBlock(row, col)
                        if hit then
                            blocks[row][col] = false
                            blockHit = row
                            break
                        end
                    end
                end
                if blockHit > 0 then break end
            end
            
            if blockHit > 0 then
                love.audio.play(hitSFX:clone())
                paddle.score = paddle.score + blockHit
                highScore = math.max(highScore, paddle.score)
            end
            
            -- Process paddle collisions
            if ball.y < margin then
                love.audio.play(bounceSFX:clone())
                ball.y = margin
                ball.dy = -ball.dy
            elseif ball.y + ballSize > paddle.y then
                -- ball is crossing into bottom
                if ball.x + ballSize > paddle.x and ball.x < paddle.x + paddleWidth then
                    -- paddle hits ball
                    love.audio.play(bounceSFX:clone())
                    ball.y = paddle.y - ballSize
                    ball.dy = -ball.dy
                    if paddle.moving then
                        ball.dx = ball.dx * (minPaddleBounce + ((maxPaddleBounce - minPaddleBounce) * love.math.random()))
                        ball.dy = ball.dy * (minPaddleBounce + ((maxPaddleBounce - minPaddleBounce) * love.math.random()))
                    end
                elseif ball.y >= resHeight - margin then
                    -- paddle misses ball
                    paddle.lives = paddle.lives - 1
                    resetPaddle()
                end
            end
            
            -- Gameover check
            if paddle.lives < 0 then
                resetGame()
            elseif remainingBlocks() == 0 then
                -- Load next stage
                love.audio.play(startSFX)
                paddle.stage = paddle.stage + 1
                resetPaddle()
                resetStage()
            end
        end
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
        -- Draw paddle
        love.graphics.rectangle("fill", paddle.x, paddle.y, paddleWidth, paddleHeight)
        
        -- Draw ball
        love.graphics.circle("fill", ball.x + (ballSize / 2), ball.y + (ballSize / 2), ballSize / 2)
        
        -- Draw blocks
        for row = 1, numRowsOfBlocks do
            for col = 1, numBlocksPerRow do
                love.graphics.setColor(blockColors[row])
                if blocks[row][col] then
                    local x, y = margin + (col - 1) * blockWidth, margin + (numRowsOfBlocks - row + 1) * blockHeight
                    love.graphics.rectangle("fill", x, y, blockWidth, blockHeight)
                end
            end
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
    
    love.graphics.setColor(255, 255, 255, 255)
    
    -- Draw score
        local scoreText = "SCORE: "..tostring(paddle.score)
    if pauseState == "GAME OVER" then scoreText = "HI-SCORE: "..tostring(highScore) end
    love.graphics.print(scoreText, (resWidth - font:getWidth(scoreText)) / 2, (margin - font:getHeight(scoreText)) / 2)
    
    -- Draw lives
    local livesText = "x"..tostring(math.max(0, paddle.lives))
    love.graphics.print(livesText, margin / 4, resHeight - margin + ((margin - font:getHeight(livesText)) / 2))
    
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
