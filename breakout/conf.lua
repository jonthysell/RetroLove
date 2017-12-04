-- breakout\conf.lua
-- Copyright (c) 2017 Jon Thysell

function love.conf(t)
    t.window.title = "RetroLove - Breakout"
    t.identity = "com.jonthysell.retrolove"
    t.window.resizable = true
    t.window.minwidth = 320
    t.window.minheight = 240
end