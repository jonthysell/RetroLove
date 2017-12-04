-- asteroids\conf.lua
-- Copyright (c) 2017 Jon Thysell

function love.conf(t)
    t.window.title = "RetroLove - Asteroids"
    t.version = "0.10.2"
    t.identity = "com.jonthysell.retrolove"
    t.window.resizable = true
    t.window.minwidth = 320
    t.window.minheight = 240
    t.accelerometerjoystick = false
    t.externalstorage = true
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.video = false
end
