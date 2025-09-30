local class = require 'middleclass'

local Card = class('Card')

function Card:initialize(image, x, y, scale)
    self.image = image
    self.x = x
    self.y = y
    self.scale = scale or 2
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.isHovered = false
    self.isDragging = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.originalX = x
    self.originalY = y
end

function Card:update(dt)
    if self.isDragging then
        local mouseX, mouseY = love.mouse.getPosition()
        self.x = mouseX - self.dragOffsetX
        self.y = mouseY - self.dragOffsetY
    end
end

function Card:draw()
    if self.isHovered then
        love.graphics.setColor(1, 1, 1, 0.8)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    local drawX = self.x
    local drawY = self.y
    if self.isDragging then
        drawY = drawY - 10
    end
    
    love.graphics.draw(self.image, drawX, drawY, 0, self.scale, self.scale)
end

function Card:isPointInside(px, py)
    return px >= self.x and px <= self.x + self.width and
           py >= self.y and py <= self.y + self.height
end

function Card:startDrag(mouseX, mouseY)
    self.isDragging = true
    self.dragOffsetX = mouseX - self.x
    self.dragOffsetY = mouseY - self.y
end

function Card:stopDrag()
    self.isDragging = false
end

function Card:setHovered(hovered)
    self.isHovered = hovered
end

function Card:resetPosition()
    self.x = self.originalX
    self.y = self.originalY
    self.isDragging = false
end

return Card
