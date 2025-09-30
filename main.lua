local class = require 'middleclass'

local Card = require 'card'
local Game = class('Game')

function Game:initialize()
    self.width = 800
    self.height = 600
    self.title = "My Love2D Game"
    self.cardImage = nil
    self.cards = {}
    self.draggedCard = nil
end

function Game:load()
    love.window.setTitle(self.title)
    love.window.setMode(self.width, self.height, {
        resizable = false,
        vsync = 1,
        minwidth = 400,
        minheight = 300
    })
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    self.cardImage = love.graphics.newImage("card.png")
    
    self:createCards()
    
    print("Game loaded successfully!")
end

function Game:update(dt)
    for _, card in ipairs(self.cards) do
        card:update(dt)
    end
end

function Game:draw()
    love.graphics.clear(0.1, 0.1, 0.1, 1)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Hello Love2D!", 10, 10)
    love.graphics.print("Press ESC to quit", 10, 30)
    
    love.graphics.setColor(0.2, 0.6, 1, 1)
    love.graphics.rectangle("fill", 50, 50, 100, 100)
    
    for _, card in ipairs(self.cards) do
        card:draw()
    end
end

function Game:createCards()
    local cardWidth = self.cardImage:getWidth()
    local cardHeight = self.cardImage:getHeight()
    local scale = 2
    local scaledWidth = cardWidth * scale
    local scaledHeight = cardHeight * scale
    local numCards = 6
    local cardSpacing = 10
    local totalWidth = (scaledWidth * numCards) + (cardSpacing * (numCards - 1))
    local startX = (self.width - totalWidth) / 2
    local y = self.height - scaledHeight - 20
    
    for i = 1, numCards do
        local x = startX + (i - 1) * (scaledWidth + cardSpacing)
        local card = Card(self.cardImage, x, y, scale)
        table.insert(self.cards, card)
    end
end

function Game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function Game:mousemoved(x, y, dx, dy)
    for _, card in ipairs(self.cards) do
        if not card.isDragging then
            card:setHovered(card:isPointInside(x, y))
        end
    end
end

function Game:mousepressed(x, y, button)
    if button == 1 then
        for _, card in ipairs(self.cards) do
            if card:isPointInside(x, y) then
                self.draggedCard = card
                card:startDrag(x, y)
                break
            end
        end
    end
end

function Game:mousereleased(x, y, button)
    if button == 1 and self.draggedCard then
        self.draggedCard:stopDrag()
        self.draggedCard = nil
    end
end

local game = Game()

function love.load()
    game:load()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.mousemoved(x, y, dx, dy)
    game:mousemoved(x, y, dx, dy)
end

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    game:mousereleased(x, y, button)
end
