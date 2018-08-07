-- menu.lua
-- Copyright (c) 2018 Jon Thysell

local game = require "game"

local Menu = game.Game:new({
    id = "menu",
    title = "Menu",
    games = {},
    selectedGame = 0,
})

function Menu:keyReleasedGame(key)
    if key == "q" or key == "escape" then
        self:exit()
    elseif key == "d" then
        self.debugMode = not self.debugMode
    elseif key == "left" or key == "right" then
        self:moveCursor(key)
    elseif key == "space" or key == "return" then
        self:clickCursor()
    end
end

function Menu:touchReleasedGame(id, x, y, dx, dy, pressure)
    
end

function Menu:drawGame()
    -- Draw to canvas
    local font = love.graphics.getFont()

    if #self.games > 0 then
        local boxSize = 80
        local boxTop = (self.resHeight - boxSize) / 2
        local boxLeftMargin = 10
        local boxRect = {}

        for i = 1, #self.games do
            local x = self.margin + (i * boxLeftMargin) + ((i - 1) * boxSize)
                
            love.graphics.setColor({255, 255, 255, 255})
            love.graphics.rectangle("line", x, boxTop, boxSize, boxSize)

            local title = tostring(self.games[i].title)
            love.graphics.print(title, x + (boxSize - font:getWidth(title)) / 2, (self.resHeight - font:getHeight(title)) / 2)

            if self.selectedGame == i then
                love.graphics.setColor({0, 255, 255, 255})
                love.graphics.rectangle("line", x, boxTop, boxSize, boxSize)
                love.graphics.print(title, x + (boxSize - font:getWidth(title)) / 2, (self.resHeight - font:getHeight(title)) / 2)
            end
        end
    end

    love.graphics.setColor({255, 255, 255, 255})
end

function Menu:exitGame()
    return nil
end

function Menu:addGame(newGame)
    self.games[#self.games + 1] = newGame
end

function Menu:moveCursor(direction)
    if #self.games > 0 then
        if direction == "left" then
            if self.selectedGame == 0 then
                self.selectedGame = #self.games
            else
                self.selectedGame = math.max(1, self.selectedGame - 1)
            end
        elseif direction == "right" then
            if self.selectedGame == 0 then
                self.selectedGame = 1
            else
                self.selectedGame = math.min(#self.games, self.selectedGame + 1)
            end
        end
        print("Cursor on game #"..tostring(self.selectedGame)..": "..tostring(self.games[self.selectedGame].id))
    end
end

function Menu:clickCursor()
    if self.selectedGame > 0 then
        local retrolove = require "retrolove"
        retrolove.switchGame(self.games[self.selectedGame])
    end
end

return {
    Menu = Menu
}