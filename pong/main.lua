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

paddleSpeed = 0.2
ballSpeed = 0.01

paddleBounce = 1.5

scoreToWin = 10

started = false

function resetBall()
    ball.x = (love.graphics.getWidth() - ballSize) / 2
    ball.y = (love.graphics.getHeight() - ballSize) / 2
    
    ball.dx = -1 + 2 * math.random()
    ball.dy = -1 + 2 * math.random()
end

function initPaddles(reset)
    paddleHeight = love.graphics.getHeight() * 0.2
    paddleWidth = love.graphics.getWidth() * 0.0125
    ballSize = paddleWidth
    
    left.x = paddleWidth
    right.x = love.graphics.getWidth() - 2 * paddleWidth
    
    if reset then
        left.y = (love.graphics.getHeight() - paddleHeight) / 2
        left.moving = false
        left.score = 0
        
        right.y = (love.graphics.getHeight() - paddleHeight) / 2
        right.moving = false
        right.score = 0
        
        resetBall()
        
        started = false
    end
end

function love.load()
    love.window.setTitle("Pong")
    math.randomseed(os.time())
    initPaddles(true)
end

function love.update()
    initPaddles(false)
    
    if not started then
        if love.keyboard.isDown("down") or love.keyboard.isDown("up") then
            started = true
        end
    else
        -- Process input for left
        if love.keyboard.isDown("down") then
            left.y = left.y + (paddleHeight * paddleSpeed)
            left.moving = true
        elseif love.keyboard.isDown("up") then
            left.y = left.y - (paddleHeight * paddleSpeed)
            left.moving = true
        else
            left.moving = false
        end
        
        -- Process AI for right
        if ball.dx > 0 then
            if ball.y + (ballSize / 2) > right.y + paddleHeight then
                right.y = right.y + (paddleHeight * paddleSpeed)
                right.moving = true
            elseif ball.y + (ballSize / 2) < right.y then
                right.y = right.y - (paddleHeight * paddleSpeed)
                right.moving = true
            else
                right.moving = false
            end
        end
        
        -- Process paddle bounds
        left.y = math.max(left.y, ballSize / 2)
        left.y = math.min(left.y, love.graphics.getHeight() - paddleHeight - (ballSize / 2))
        right.y = math.max(right.y, ballSize / 2)
        right.y = math.min(right.y, love.graphics.getHeight() - paddleHeight - (ballSize / 2))
        
        -- Process ball movement
        ball.dx = math.min(1, math.max(ball.dx, -1))
        ball.dy = math.min(1, math.max(ball.dy, -1))
        
        ball.x = ball.x + (ball.dx * ballSpeed * math.min(love.graphics.getHeight(), love.graphics.getWidth()))
        ball.y = ball.y + (ball.dy * ballSpeed * math.min(love.graphics.getHeight(), love.graphics.getWidth()))
        
        -- Process wall/ball collisions
        if ball.y < 0 then
            ball.y = 0
            ball.dy = -ball.dy
        elseif ball.y > love.graphics.getHeight() - ballSize then
            ball.y = love.graphics.getHeight() - ballSize
            ball.dy = -ball.dy
        end
        
        if ball.x < left.x + paddleWidth then
            -- ball is crossing into left
            if ball.y > left.y - ballSize and ball.y < left.y + paddleHeight then
                -- left hits ball
                ball.x = left.x + paddleWidth
                ball.dx = -ball.dx
                if left.moving then
                    ball.dx = ball.dx * paddleBounce
                    ball.dy = ball.dy * paddleBounce
                else
                    ball.dx = ball.dx / paddleBounce
                    ball.dy = ball.dy / paddleBounce
                end
            else
                -- left misses ball
                right.score = right.score + 1
                resetBall()
            end
        elseif ball.x + ballSize > right.x then
            -- ball is crossing into right
            if ball.y > right.y - ballSize and ball.y < right.y + paddleHeight then
                -- right hits ball
                ball.x = right.x - ballSize
                ball.dx = -ball.dx
                if right.moving then
                    ball.dx = ball.dx * paddleBounce
                    ball.dy = ball.dy * paddleBounce
                else
                    ball.dx = ball.dx / paddleBounce
                    ball.dy = ball.dy / paddleBounce
                end
            else
                -- right misses ball
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
    -- Draw score
    love.graphics.print(left.score, (love.graphics.getWidth() / 2) - (ballSize * 2), ballSize / 2)
    love.graphics.print(right.score, (love.graphics.getWidth() / 2) + ballSize, ballSize / 2)
    
    -- Draw paddles
    love.graphics.rectangle("fill", left.x, left.y, paddleWidth, paddleHeight)
    love.graphics.rectangle("fill", right.x, right.y, paddleWidth, paddleHeight)
    
    -- Draw ball
    love.graphics.rectangle("fill", ball.x, ball.y, ballSize, ballSize)
end
