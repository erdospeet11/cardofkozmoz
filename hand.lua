local class = require 'middleclass'

local Hand = class('Hand')

function Hand:initialize(cardImage, screenWidth, screenHeight)
    self.cardImage = cardImage
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.cards = {}
    self.scale = 2
    self.cardWidth = cardImage:getWidth() * self.scale
    self.cardHeight = cardImage:getHeight() * self.scale
    self.cardSpacing = 10
    self.bottomPadding = 20
end

function Hand:addCard(card)
    table.insert(self.cards, card)
    self:repositionCards()
end

function Hand:removeCard(card)
    for i, c in ipairs(self.cards) do
        if c == card then
            table.remove(self.cards, i)
            self:repositionCards()
            break
        end
    end
end

function Hand:repositionCards()
    local numCards = #self.cards
    if numCards == 0 then return end
    
    local totalWidth = (self.cardWidth * numCards) + (self.cardSpacing * (numCards - 1))
    local startX = (self.screenWidth - totalWidth) / 2
    local y = self.screenHeight - self.cardHeight - self.bottomPadding
    
    for i, card in ipairs(self.cards) do
        local x = startX + (i - 1) * (self.cardWidth + self.cardSpacing)
        card.x = x
        card.y = y
        card.originalX = x
        card.originalY = y
    end
end

function Hand:update(dt)
    for _, card in ipairs(self.cards) do
        card:update(dt)
    end
end

function Hand:draw()
    for _, card in ipairs(self.cards) do
        card:draw()
    end
end

function Hand:getCards()
    return self.cards
end

return Hand
