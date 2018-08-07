-- game.lua
-- Copyright (c) 2018 Jon Thysell

local Game = {
    id = "",
    title = "",
    debugMode = false,
    resWidth = 320,
    resHeight = 240
}

function Game:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Game:init()
    self.canvas = love.graphics.newCanvas(self.resWidth, self.resHeight)
    self.canvas:setFilter("nearest", "nearest", 0)

    self:resize()

    if self.initGame then self:initGame() end
    if self.loadState then self:loadState() end
    if self.reset then self:reset() end
end

function Game:getInput()
    return {}
end

function Game:update(dt)
    self:updateGame(dt, self:getInput())
end

function Game:updateGame(dt, input)
    
end

function Game:draw()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    
    self:drawGame()

    love.graphics.setCanvas()
    love.graphics.draw(self.canvas, self.canvasOriginX, self.canvasOriginY, 0, self.scale, self.scale)

    if self.drawOverlay then self:drawOverlay() end
end

function Game:drawGame(dt, input)
    local font = love.graphics.getFont()

    love.graphics.setColor({255, 255, 255})
    local centerText = tostring(self.title)
    love.graphics.print(centerText, (self.resWidth - font:getWidth(centerText)) / 2, (self.resHeight - font:getHeight(centerText)) / 2)
end

function Game:resize()
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()

    self.scale = math.min(self.screenWidth / self.resWidth, self.screenHeight / self.resHeight)
    self.canvasOriginX = (self.screenWidth - self.resWidth * self.scale) / 2
    self.canvasOriginY = (self.screenHeight - self.resHeight * self.scale) / 2
end

function Game:exitGame()
    if self.saveState then self:saveState() end
    if self.exitGame then self:exitGame() end

    local retrolove = require "retrolove"
    retrolove.switchGame(retrolove.mainMenu)
end

return {
    Game = Game
}