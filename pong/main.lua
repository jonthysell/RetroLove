-- pong\main.lua
-- Copyright (c) 2017 Jon Thysell

resWidth = 320
resHeight = 240

margin = 20

scoreToWin = 10

paddleSpeed = 2
ballSpeed = 0.5

paddleBounce = 1.1

debugMode = false

screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

function resetBall()
    ball = {
        x = (resWidth - ballSize) / 2,
        y = (resHeight - ballSize) / 2,
        dx = 0.5 + 0.1 * love.math.random(),
        dy = 0.5 + 0.1 * love.math.random()
    }

    if love.math.random() > 0.5 then ball.dx = -ball.dx end
    if love.math.random() > 0.5 then ball.dy = -ball.dy end
end

function resetPaddles()
    paddleHeight = resHeight * 0.2
    paddleWidth = resWidth * 0.0125
    ballSize = paddleWidth

    left = {
        x = paddleWidth + margin,
        y = (resHeight - paddleHeight) / 2,
        moving = false,
        score = 0,
    }

    right = {
        x = resWidth - (2 * paddleWidth + margin),
        y = (resHeight - paddleHeight) / 2,
        moving = false,
        score = 0,
    }

    pauseState = "GAME OVER"
    newGame = true
end

function getInput()
    if love.keyboard.isDown("down") then
        return "down"
    elseif love.keyboard.isDown("up") then
        return "up"
    end

    if love.touch then
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
    resetPaddles()
    resetBall()

    -- Init offscreen graphics
    canvas = love.graphics.newCanvas(resWidth, resHeight)
    canvas:setFilter("nearest", "nearest", 0)
    love.graphics.setFont(love.graphics.newFont(margin * .7))

    -- Init sounds
    bounceSFX = love.audio.newSource("bounce.ogg", "static")
    hitSFX = love.audio.newSource("hit.ogg", "static")
    scoreSFX = love.audio.newSource("score.ogg", "static")
end

function love.resize()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.update(dt)
    local input = getInput()

    if not pauseState then
        if newGame then
            newGame = false
        end

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
        left.y = math.max(left.y, margin)
        left.y = math.min(left.y, resHeight - paddleHeight - margin)
        right.y = math.max(right.y, margin)
        right.y = math.min(right.y, resHeight - paddleHeight - margin)

        -- Process ball movement
        ball.dx = math.min(1, math.max(ball.dx, -1))
        ball.dy = math.min(1, math.max(ball.dy, -1))

        ball.x = ball.x + (ball.dx * ballSpeed * math.min(resHeight, resWidth) * dt)
        ball.y = ball.y + (ball.dy * ballSpeed * math.min(resHeight, resWidth) * dt)

        -- Process wall/ball collisions
        if ball.y < margin then
            love.audio.play(bounceSFX:clone())
            ball.y = margin
            ball.dy = -ball.dy
        elseif ball.y > resHeight - ballSize - margin then
            love.audio.play(bounceSFX:clone())
            ball.y = resHeight - ballSize - margin
            ball.dy = -ball.dy
        end

        if ball.x < left.x + paddleWidth then
            -- ball is crossing into left
            if ball.x > left.x and ball.y > left.y - ballSize and ball.y < left.y + paddleHeight then
                -- left hits ball
                love.audio.play(hitSFX:clone())
                ball.x = left.x + paddleWidth
                ball.dx = -ball.dx
                if left.moving then
                    ball.dx = ball.dx * paddleBounce
                    ball.dy = ball.dy * paddleBounce
                end
            elseif ball.x + ballSize <= margin then
                -- left misses ball
                love.audio.play(scoreSFX)
                right.score = right.score + 1
                resetBall()
            end
        elseif ball.x + ballSize > right.x then
            -- ball is crossing into right
            if ball.x + ballSize < right.x + paddleWidth and ball.y > right.y - ballSize and ball.y < right.y + paddleHeight then
                -- right hits ball
                love.audio.play(hitSFX:clone())
                ball.x = right.x - ballSize
                ball.dx = -ball.dx
                if right.moving then
                    ball.dx = ball.dx * paddleBounce
                    ball.dy = ball.dy * paddleBounce
                end
            elseif ball.x >= resWidth - margin then
                -- right misses ball
                love.audio.play(scoreSFX)
                left.score = left.score + 1
                resetBall()
            end
        end

        if left.score == scoreToWin or right.score == scoreToWin then
            resetPaddles()
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
        -- Draw center line
        love.graphics.line(resWidth / 2, margin, resWidth / 2, resHeight - margin)

        -- Draw paddles
        love.graphics.rectangle("fill", left.x, left.y, paddleWidth, paddleHeight)
        love.graphics.rectangle("fill", right.x, right.y, paddleWidth, paddleHeight)

        -- Draw ball
        love.graphics.rectangle("fill", ball.x, ball.y, ballSize, ballSize)
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
    local leftScoreText = tostring(left.score)
    love.graphics.print(leftScoreText, (resWidth * .25) - (font:getWidth(leftScoreText)/ 2), ballSize / 2)
    local rightScoreText = tostring(right.score)
    love.graphics.print(rightScoreText, (resWidth * .75) - (font:getWidth(rightScoreText)/ 2), ballSize / 2)

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
