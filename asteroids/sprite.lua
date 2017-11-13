-- asteroids\sprite.lua
-- Copyright (c) 2017 Jon Thysell

-- Sprite
Sprite = {
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    r = 0,
}

function Sprite:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Sprite:getMirrors(xmin, xmax, ymin, ymax)
    local mirrors = {}
    
    if self.x - self.r < xmin then table.insert(mirrors, { x = self.x + (xmax - xmin), y = self.y }) end
    if self.x + self.r > xmax then table.insert(mirrors, { x = self.x - (xmax - xmin), y = self.y }) end
    if self.y - self.r < ymin then table.insert(mirrors, { x = self.x, y = self.y + (ymax - ymin) }) end
    if self.y + self.r > ymax then table.insert(mirrors, { x = self.x, y = self.y - (ymax - ymin) }) end
    
    return mirrors
end

function Sprite:move(dt, xmin, xmax, ymin, ymax)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    
    -- Process wrap around
    if xmin and self.x < xmin then self.x = xmax end
    if xmax and self.x > xmax then self.x = xmin end
    if ymin and self.y < ymin then self.y = ymax end
    if ymax and self.y > ymax then self.y = ymin end
    
end

function Sprite:draw(ox, oy)
    local ox = ox or self.x
    local oy = oy or self.y
    
    love.graphics.circle("fill", ox, oy, self.r)
end

-- Ship
Ship = Sprite:new({
    r = 6,
    heading = 0
})

function Ship:draw(ox, oy)
    local ox = ox or self.x
    local oy = oy or self.y
    
    local p = {
        6, 0,
        -6, -4,
        -4, 0,
        -6, 4,
    }
    
    for i = 1, #p, 2 do
        local x, y = p[i], p[i+1]
        p[i] = ox + (x * math.cos(self.heading)) - (y * math.sin(self.heading))
        p[i+1] = oy - ((x * math.sin(self.heading)) + (y * math.cos(self.heading)))
    end
    
    love.graphics.polygon("fill", p)
end

-- Shot
Shot = Sprite:new({
    r = 1,
    timeRemaining = 0,
})

-- Asteroid
Asteroid = Sprite:new({
    r = 16,
})

function Asteroid:split(speedMultiplier)
    local speedMultiplier = speedMultiplier or 1
    
    local m = math.sqrt(self.dx^2 + self.dy^2)
    local d = math.atan(self.dy / self.dx)
    
    local a1 = Asteroid:new({
        x = self.x,
        y = self.y,
        dx = speedMultiplier * m * math.cos(d + math.rad(90)),
        dy = speedMultiplier * m * math.sin(d + math.rad(90)),
        r = self.r / 2
    })
    
    local a2 = Asteroid:new({
        x = self.x,
        y = self.y,
        dx = speedMultiplier * m * math.cos(d - math.rad(90)),
        dy = speedMultiplier * m * math.sin(d - math.rad(90)),
        r = self.r / 2
    })
    
    return a1, a2
end

function Asteroid:draw(ox, oy)
    local ox = ox or self.x
    local oy = oy or self.y
    
    love.graphics.circle("line", ox, oy, self.r)
end
