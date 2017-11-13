-- asteroids\sprite.lua
-- Copyright (c) 2017 Jon Thysell

-- Sprite
Sprite = {
    x = 0,
    y = 0,
    mv = { dx = 0, dy = 0 },
    r = 0,
}

function Sprite:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Sprite:move(xmin, xmax, ymin, ymax)
    self.x = self.x + self.mv.dx
    self.y = self.y + self.mv.dy
    
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
-- TODO

-- Asteroid
-- TODO