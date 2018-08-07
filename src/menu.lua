-- menu.lua
-- Copyright (c) 2018 Jon Thysell

local game = require "game"

local Menu = game.Game:new({
    id = "menu",
    title = "Menu",
    games = {},
})

function Menu:addGame(newGame)
    self.games[#self.games + 1] = newGame
end

return {
    Menu = Menu
}