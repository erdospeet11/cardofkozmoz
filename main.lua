local GameManager = require 'gamemanager'

local gameManager = nil
local screenWidth = 800
local screenHeight = 600
local title = "Card of Kozmoz"
local cardImage = nil

function love.load()
    love.window.setTitle(title)
    love.window.setMode(screenWidth, screenHeight, {
        resizable = false,
        vsync = 1,
        minwidth = 400,
        minheight = 300
    })
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    cardImage = love.graphics.newImage("card.png")
    
    gameManager = GameManager(cardImage, screenWidth, screenHeight)
    
    print("Card of Kozmoz loaded successfully!")
end

function love.update(dt)
    if gameManager then
        gameManager:update(dt)
    end
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1, 1)
    
    if gameManager then
        gameManager:draw()
    end
end

function love.keypressed(key)
    if gameManager then
        gameManager:handleKeyPressed(key)
    end
end

function love.mousemoved(x, y, dx, dy)
    if gameManager then
        gameManager:handleMouseMoved(x, y)
    end
end

function love.mousepressed(x, y, button)
    if gameManager then
        gameManager:handleMousePressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if gameManager then
        gameManager:handleMouseReleased(x, y, button)
    end
end
