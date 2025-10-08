local class = require 'middleclass'
local Hand = require 'hand'
local Card = require 'card'

local Player = class('Player')

function Player:initialize(name, cardImage, screenWidth, screenHeight, isAI)
    self.name = name or "Player"
    self.isAI = isAI or false
    self.cardImage = cardImage
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    
    self.hand = Hand(cardImage, screenWidth, screenHeight)

    self.playedCards = {}

    self.draggedCard = nil
    
    self.score = 0
    self.health = 100
    self.energy = 10
    self.maxEnergy = 10
end

function Player:update(dt)
    self.hand:update(dt)
    
    for _, card in ipairs(self.playedCards) do
        card:update(dt)
    end
end

function Player:draw()
    for _, card in ipairs(self.playedCards) do
        card:draw()
    end
    
    self.hand:draw()
    
    self:drawInfo()
end

function Player:drawInfo()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.name, 10, 10)
    love.graphics.print("Score: " .. self.score, 10, 30)
    love.graphics.print("Health: " .. self.health, 10, 50)
    love.graphics.print("Energy: " .. self.energy .. "/" .. self.maxEnergy, 10, 70)
end

function Player:drawCard(card)
    self.hand:addCard(card)
end

function Player:playCard(card)
    self.hand:removeCard(card)
    
    table.insert(self.playedCards, card)
    
    card:stopDrag()
end

function Player:returnCardToHand(card)
    for i, c in ipairs(self.playedCards) do
        if c == card then
            table.remove(self.playedCards, i)
            break
        end
    end
    
    self.hand:addCard(card)
end

function Player:getCards()
    return self.hand:getCards()
end

function Player:getPlayedCards()
    return self.playedCards
end

function Player:startDraggingCard(x, y)
    for _, card in ipairs(self.hand:getCards()) do
        if card:isPointInside(x, y) then
            self.draggedCard = card
            card:startDrag(x, y)
            return true
        end
    end
    
    for _, card in ipairs(self.playedCards) do
        if card:isPointInside(x, y) then
            self.draggedCard = card
            card:startDrag(x, y)
            return true
        end
    end
    
    return false
end

function Player:stopDraggingCard()
    if self.draggedCard then
        self:playCard(self.draggedCard)
        self.draggedCard = nil
    end
end

function Player:updateCardHoverStates(x, y)
    for _, card in ipairs(self.hand:getCards()) do
        if not card.isDragging then
            card:setHovered(card:isPointInside(x, y))
        end
    end
    
    for _, card in ipairs(self.playedCards) do
        if not card.isDragging then
            card:setHovered(card:isPointInside(x, y))
        end
    end
end

function Player:addScore(points)
    self.score = self.score + points
end

function Player:modifyHealth(amount)
    self.health = self.health + amount
    if self.health < 0 then
        self.health = 0
    end
end

function Player:modifyEnergy(amount)
    self.energy = self.energy + amount
    if self.energy < 0 then
        self.energy = 0
    elseif self.energy > self.maxEnergy then
        self.energy = self.maxEnergy
    end
end

function Player:resetEnergy()
    self.energy = self.maxEnergy
end

function Player:getHandSize()
    return #self.hand:getCards()
end

function Player:isAlive()
    return self.health > 0
end

return Player

