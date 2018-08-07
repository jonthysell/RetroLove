-- main.lua
-- Copyright (c) 2018 Jon Thysell

local retrolove = require "retrolove"

function love.load() retrolove.load() end
function love.update(dt) retrolove.update(dt) end
function love.draw() retrolove.draw() end

function love.resize() retrolove.resize() end
function love.focus(f) retrolove.activate(f) end
function love.visible(v) retrolove.activate(v) end
function love.quit() retrolove.activate(false) end