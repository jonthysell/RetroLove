resWidth = 320
resHeight = 240

paddleHeight = 0
paddleWidth = 0
ballSize = 0

left = {
    x = 0,
    y = 0,
    moving = false,
    score = 0
}

right = {
    x = 0,
    y = 0,
    moving = false,
    score = 0
}

ball = {
    x = 0,
    y = 0,
    dx = 0,
    dy = 0
}

paddleSpeed = 2
ballSpeed = 0.5

paddleBounce = 1.1

scoreToWin = 10

started = false

debugMode = false

function resetBall()
    ball.x = (resWidth - ballSize) / 2
    ball.y = (resHeight - ballSize) / 2
    
    ball.dx = 0.5 + 0.5 * math.random()
    if math.random() > 0.5 then ball.dx = -ball.dx end
    ball.dy = 0.5 + 0.5 * math.random()
    if math.random() > 0.5 then ball.dy = -ball.dy end
end

function initPaddles(reset)
    paddleHeight = resHeight * 0.2
    paddleWidth = resWidth * 0.0125
    ballSize = paddleWidth
    
    left.x = paddleWidth
    right.x = resWidth - 2 * paddleWidth
    
    if reset then
        left.y = (resHeight - paddleHeight) / 2
        left.moving = false
        left.score = 0
        
        right.y = (resHeight - paddleHeight) / 2
        right.moving = false
        right.score = 0
        
        resetBall()
        
        started = false
    end
end

function getInput()
    if love.keyboard.isDown("down") then
        return "down"
    elseif love.keyboard.isDown("up") then
        return "up"
    end
    
    if love.touch then
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        local touches = love.touch.getTouches()
        for i, id in ipairs(touches) do
            local x, y = love.touch.getPosition(id)
            if x <= screenWidth * .4 or x >= screenWidth * .6 then
                if y < screenHeight / 2 then
                    return "up"
                else
                    return "down"
                end
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
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
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
    initPaddles(true)
    canvas = love.graphics.newCanvas(resWidth, resHeight)
    
    bounceSFX = love.audio.newSource("bounce.ogg", "static")
    hitSFX = love.audio.newSource("hit.ogg", "static")
    scoreSFX = love.audio.newSource("score.ogg", "static")
end

function love.update(dt)
    input = getInput()
    
    if not started then
        if input then
            started = true
        end
    else
        -- Process input for left
        if input == "down" then
            left.y = left.y + (paddleHeight * paddleSpeed * dt)
            left.moving = true
        elseif input == "up" then
            left.y = left.y - (paddleHeight * paddleSpeed * dt)
            left.moving = true
        else
            left.moving = false
        end
        
        -- Process AI for right
        if ball.dx > 0 then
            if ball.y + (ballSize / 2) > right.y + paddleHeight then
                right.y = right.y + (paddleHeight * paddleSpeed * dt)
                right.moving = true
            elseif ball.y + (ballSize / 2) < right.y then
                right.y = right.y - (paddleHeight * paddleSpeed * dt)
                right.moving = true
            else
                right.moving = false
            end
        end
        
        -- Process paddle bounds
        left.y = math.max(left.y, ballSize / 2)
        left.y = math.min(left.y, resHeight - paddleHeight - (ballSize / 2))
        right.y = math.max(right.y, ballSize / 2)
        right.y = math.min(right.y, resHeight - paddleHeight - (ballSize / 2))
        
        -- Process ball movement
        ball.dx = math.min(1, math.max(ball.dx, -1))
        ball.dy = math.min(1, math.max(ball.dy, -1))
        
        ball.x = ball.x + (ball.dx * ballSpeed * math.min(resHeight, resWidth) * dt)
        ball.y = ball.y + (ball.dy * ballSpeed * math.min(resHeight, resWidth) * dt)
        
        -- Process wall/ball collisions
        if ball.y < 0 then
            love.audio.play(bounceSFX)
            ball.y = 0
            ball.dy = -ball.dy
        elseif ball.y > resHeight - ballSize then
            love.audio.play(bounceSFX)
            ball.y = resHeight - ballSize
            ball.dy = -ball.dy
        end
        
        if ball.x < left.x + paddleWidth then
            -- ball is crossing into left
            if ball.x > left.x and ball.y > left.y - ballSize and ball.y < left.y + paddleHeight then
                -- left hits ball
                love.audio.play(hitSFX)
                ball.x = left.x + paddleWidth
                ball.dx = -ball.dx
                if left.moving then
                    ball.dx = ball.dx * paddleBounce
                    ball.dy = ball.dy * paddleBounce
                end
            elseif ball.x + ballSize <= 0 then
                -- left misses ball
                love.audio.play(scoreSFX)
                right.score = right.score + 1
                resetBall()
            end
        elseif ball.x + ballSize > right.x then
            -- ball is crossing into right
            if ball.x + ballSize < right.x + paddleWidth and ball.y > right.y - ballSize and ball.y < right.y + paddleHeight then
                -- right hits ball
                love.audio.play(hitSFX)
                ball.x = right.x - ballSize
                ball.dx = -ball.dx
                if right.moving then
                    ball.dx = ball.dx * paddleBounce
                    ball.dy = ball.dy * paddleBounce
                end
            elseif ball.x >= resWidth then
                -- right misses ball
                love.audio.play(scoreSFX)
                left.score = left.score + 1
                resetBall()
            end
        end
        
        if left.score == scoreToWin or right.score == scoreToWin then
            initPaddles(true)
        end
    end
end

function love.draw()
    -- Draw to canvas
    love.graphics.setCanvas(canvas)
    
    love.graphics.clear()

    -- Draw score
    love.graphics.print(left.score, (resWidth * .25) - (ballSize * 2), ballSize / 2)
    love.graphics.print(right.score, (resWidth * .75) + ballSize, ballSize / 2)
    
    -- Draw paddles
    love.graphics.rectangle("fill", left.x, left.y, paddleWidth, paddleHeight)
    love.graphics.rectangle("fill", right.x, right.y, paddleWidth, paddleHeight)
    
    -- Draw ball
    love.graphics.rectangle("fill", ball.x, ball.y, ballSize, ballSize)
    
    -- Draw Debug Info
    if debugMode then
       love.graphics.print("FPS: "..tostring(love.timer.getFPS()), resWidth - 60, resHeight - 20)
    end
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Draw canvas to screen
    love.graphics.setCanvas()
    
    scale = math.min(screenWidth / resWidth, screenHeight / resHeight)
    love.graphics.draw(canvas, (screenWidth - resWidth * scale) / 2, (screenHeight - resHeight * scale) / 2, 0, scale, scale)
end
