local class = require 'middleclass'

local Card = require 'card'
local Hand = require 'hand'
local Deck = require 'deck'
local Game = class('Game')

function Game:initialize()
    self.width = 800
    self.height = 600
    self.title = "My Love2D Game"
    self.cardImage = nil
    self.hand = nil
    self.deck = nil
    self.draggedCard = nil
    self.playedCards = {} -- Cards that have been dropped/played
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
    
    -- Create hand
    self.hand = Hand(self.cardImage, self.width, self.height)
    
    -- Create deck positioned at right middle
    local deckScale = 2
    local deckWidth = self.cardImage:getWidth() * deckScale
    local deckHeight = self.cardImage:getHeight() * deckScale
    local deckX = self.width - deckWidth - 20
    local deckY = (self.height - deckHeight) / 2
    self.deck = Deck(self.cardImage, deckX, deckY, deckScale)
    
    print("Game loaded successfully!")
end

function Game:update(dt)
    self.hand:update(dt)
    self.deck:update(dt)
    
    -- Update played cards
    for _, card in ipairs(self.playedCards) do
        card:update(dt)
    end
end

function Game:draw()
    love.graphics.clear(0.1, 0.1, 0.1, 1)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Hello Love2D!", 10, 10)
    love.graphics.print("Press ESC to quit", 10, 30)
    love.graphics.print("Click the deck to draw cards", 10, 50)
    
    love.graphics.setColor(0.2, 0.6, 1, 1)
    love.graphics.rectangle("fill", 50, 50, 100, 100)
    
    -- Draw deck first (behind cards)
    self.deck:draw()
    
    -- Draw played cards
    for _, card in ipairs(self.playedCards) do
        card:draw()
    end
    
    -- Draw hand cards (on top)
    self.hand:draw()
end

function Game:drawCardFromDeck()
    if self.deck:drawCard() then
        local card = Card(self.cardImage, 0, 0, 2)
        self.hand:addCard(card)
        self.deck:updateTooltip("Click to draw")
        return true
    end
    return false
end

function Game:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function Game:mousemoved(x, y, dx, dy)
    -- Update hover state for deck
    self.deck:setHovered(self.deck:isPointInside(x, y))
    
    -- Update hover state for cards in hand
    for _, card in ipairs(self.hand:getCards()) do
        if not card.isDragging then
            card:setHovered(card:isPointInside(x, y))
        end
    end
    
    -- Update hover state for played cards
    for _, card in ipairs(self.playedCards) do
        if not card.isDragging then
            card:setHovered(card:isPointInside(x, y))
        end
    end
end

function Game:mousepressed(x, y, button)
    if button == 1 then
        -- Check if deck was clicked
        if self.deck:isPointInside(x, y) then
            self:drawCardFromDeck()
            return
        end
        
        -- Check if any card in hand was clicked
        for _, card in ipairs(self.hand:getCards()) do
            if card:isPointInside(x, y) then
                self.draggedCard = card
                card:startDrag(x, y)
                break
            end
        end
        
        -- Check if any played card was clicked
        if not self.draggedCard then
            for _, card in ipairs(self.playedCards) do
                if card:isPointInside(x, y) then
                    self.draggedCard = card
                    card:startDrag(x, y)
                    break
                end
            end
        end
    end
end

function Game:mousereleased(x, y, button)
    if button == 1 and self.draggedCard then
        -- Remove the card from hand and add to played cards
        self.hand:removeCard(self.draggedCard)
        table.insert(self.playedCards, self.draggedCard)
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
