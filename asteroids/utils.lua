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

function collision(s1, s2)
    return false
end