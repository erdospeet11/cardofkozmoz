local class = require 'middleclass'

local Deck = class('Deck')

function Deck:initialize(image, x, y, scale)
    self.image = image
    self.x = x
    self.y = y
    self.scale = scale or 2
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.isHovered = false
    self.cardsRemaining = 30 -- Example deck size
    
    -- Tooltip settings
    self.tooltip = {
        text = "Draw Deck\nClick to draw a card",
        padding = 10,
        font = love.graphics.newFont(12)
    }
end

function Deck:update(dt)
    -- Can add animations or other updates here
end

function Deck:draw()
    -- Draw the deck
    if self.isHovered then
        love.graphics.setColor(0.9, 0.9, 1, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
    
    -- Draw cards remaining text
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(tostring(self.cardsRemaining), self.x + self.width / 2 - 8, self.y + self.height / 2 - 6)
    
    -- Draw tooltip if hovered
    if self.isHovered then
        self:drawTooltip()
    end
end

function Deck:drawTooltip()
    local mouseX, mouseY = love.mouse.getPosition()
    
    -- Calculate tooltip dimensions
    local font = self.tooltip.font
    local text = self.tooltip.text
    local padding = self.tooltip.padding
    
    love.graphics.setFont(font)
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    local maxWidth = 0
    for _, line in ipairs(lines) do
        local lineWidth = font:getWidth(line)
        if lineWidth > maxWidth then
            maxWidth = lineWidth
        end
    end
    
    local tooltipWidth = maxWidth + padding * 2
    local tooltipHeight = font:getHeight() * #lines + padding * 2
    
    -- Position tooltip to the left of the deck
    local tooltipX = self.x - tooltipWidth - 10
    local tooltipY = self.y
    
    -- Make sure tooltip doesn't go off screen
    if tooltipX < 0 then
        tooltipX = self.x + self.width + 10
    end
    
    -- Draw tooltip background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 5, 5)
    
    -- Draw tooltip border
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 5, 5)
    
    -- Draw tooltip text
    love.graphics.setColor(1, 1, 1, 1)
    for i, line in ipairs(lines) do
        love.graphics.print(line, tooltipX + padding, tooltipY + padding + (i - 1) * font:getHeight())
    end
end

function Deck:isPointInside(px, py)
    return px >= self.x and px <= self.x + self.width and
           py >= self.y and py <= self.y + self.height
end

function Deck:setHovered(hovered)
    self.isHovered = hovered
end

function Deck:drawCard()
    if self.cardsRemaining > 0 then
        self.cardsRemaining = self.cardsRemaining - 1
        return true
    end
    return false
end

function Deck:updateTooltip(info)
    self.tooltip.text = "Draw Deck\n" .. info .. "\nCards remaining: " .. self.cardsRemaining
end

return Deck
