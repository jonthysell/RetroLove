-- asteroids\utils.lua
-- Copyright (c) 2017 Jon Thysell

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

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function collision(c1, c2)
    return distance(c1.x, c1.y, c2.x, c2.y) < (c1.r + c2.r)
end

function passThreshold(before, after, threshold)
    return math.floor(before / threshold) < math.floor(after / threshold)
end