-- retrolove.lua
-- Copyright (c) 2018 Jon Thysell

local retrolove = {}

function retrolove.load()
    local menu = require "menu"
    retrolove.mainMenu = menu.Menu:new({})
    -- load games
    
    retrolove.currentGame = retrolove.mainMenu
    retrolove.currentGame:init()
end

function retrolove.resize()
    retrolove.currentGame:resize()
end

function retrolove.update(dt)
    retrolove.currentGame:update(dt)
end

function retrolove.draw()
    retrolove.currentGame:draw()
end

function retrolove.activate(isActive)
    if not isActive then
        if retrolove.currentGame.saveState then retrolove.currentGame:saveState() end
    end
end

function retrolove.switchGame(game)
    if game then
        self.curentGame = game
        self.currentGame:init()
    else
        love.event.quit()
    end
end

return retrolove