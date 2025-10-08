local class = require 'middleclass'
local Player = require 'player'
local Deck = require 'deck'

local GameManager = class('GameManager')

function GameManager:initialize(cardImage, screenWidth, screenHeight)
    self.cardImage = cardImage
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    
    -- Game state
    self.state = "menu" -- menu, playing, paused, gameover
    self.turn = 1
    self.currentPlayerIndex = 1
    
    -- Players
    self.players = {}
    
    -- Deck
    self.deck = nil
    
    -- Game settings
    self.maxPlayers = 4
    self.startingHandSize = 5
    self.drawsPerTurn = 1
end

function GameManager:setupGame(numPlayers)
    numPlayers = numPlayers or 1
    
    -- Create players
    self.players = {}
    for i = 1, numPlayers do
        local playerName = "Player " .. i
        local isAI = i > 1 -- First player is human, others are AI
        local player = Player(playerName, self.cardImage, self.screenWidth, self.screenHeight, isAI)
        table.insert(self.players, player)
    end
    
    -- Create deck
    local deckScale = 2
    local deckWidth = self.cardImage:getWidth() * deckScale
    local deckHeight = self.cardImage:getHeight() * deckScale
    local deckX = self.screenWidth - deckWidth - 20
    local deckY = (self.screenHeight - deckHeight) / 2
    self.deck = Deck(self.cardImage, deckX, deckY, deckScale)
    
    -- Deal starting hands
    for _ = 1, self.startingHandSize do
        for _, player in ipairs(self.players) do
            self:drawCardForPlayer(player)
        end
    end
    
    self.state = "playing"
    self.currentPlayerIndex = 1
    print("Game started with " .. numPlayers .. " players")
end

function GameManager:update(dt)
    if self.state ~= "playing" then
        return
    end
    
    -- Update deck
    if self.deck then
        self.deck:update(dt)
    end
    
    -- Update all players
    for _, player in ipairs(self.players) do
        player:update(dt)
    end
    
    -- Check for game over conditions
    self:checkGameOver()
end

function GameManager:draw()
    if self.state == "menu" then
        self:drawMenu()
        return
    elseif self.state == "gameover" then
        self:drawGameOver()
        return
    end
    
    -- Draw deck
    if self.deck then
        self.deck:draw()
    end
    
    -- Draw all players
    for _, player in ipairs(self.players) do
        player:draw()
    end
    
    -- Draw turn indicator
    self:drawTurnIndicator()
end

function GameManager:drawMenu()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Card Game", 0, self.screenHeight / 2 - 40, self.screenWidth, "center")
    love.graphics.printf("Press SPACE to start", 0, self.screenHeight / 2, self.screenWidth, "center")
    love.graphics.printf("Press 1-4 to select number of players", 0, self.screenHeight / 2 + 20, self.screenWidth, "center")
end

function GameManager:drawGameOver()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Game Over!", 0, self.screenHeight / 2 - 40, self.screenWidth, "center")
    
    -- Show winner
    local winner = self:getWinner()
    if winner then
        love.graphics.printf(winner.name .. " wins with " .. winner.score .. " points!", 0, self.screenHeight / 2, self.screenWidth, "center")
    end
    
    love.graphics.printf("Press R to restart", 0, self.screenHeight / 2 + 40, self.screenWidth, "center")
end

function GameManager:drawTurnIndicator()
    if #self.players > 1 then
        local currentPlayer = self:getCurrentPlayer()
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.printf("Turn: " .. self.turn .. " - " .. currentPlayer.name .. "'s turn", 0, 5, self.screenWidth, "center")
    end
end

function GameManager:drawCardForPlayer(player)
    if self.deck and self.deck:drawCard() then
        local Card = require 'card'
        local card = Card(self.cardImage, 0, 0, 2)
        player:drawCard(card)
        self.deck:updateTooltip("Click to draw")
        return true
    end
    return false
end

function GameManager:getCurrentPlayer()
    if #self.players > 0 then
        return self.players[self.currentPlayerIndex]
    end
    return nil
end

function GameManager:nextTurn()
    -- Reset current player's energy
    local currentPlayer = self:getCurrentPlayer()
    if currentPlayer then
        currentPlayer:resetEnergy()
    end
    
    -- Move to next player
    self.currentPlayerIndex = self.currentPlayerIndex + 1
    if self.currentPlayerIndex > #self.players then
        self.currentPlayerIndex = 1
        self.turn = self.turn + 1
    end
    
    -- Draw cards for new current player
    currentPlayer = self:getCurrentPlayer()
    if currentPlayer then
        for i = 1, self.drawsPerTurn do
            self:drawCardForPlayer(currentPlayer)
        end
    end
    
    print("Turn " .. self.turn .. " - " .. currentPlayer.name .. "'s turn")
end

function GameManager:checkGameOver()
    local alivePlayers = 0
    for _, player in ipairs(self.players) do
        if player:isAlive() then
            alivePlayers = alivePlayers + 1
        end
    end
    
    if alivePlayers <= 1 then
        self.state = "gameover"
    end
end

function GameManager:getWinner()
    local winner = nil
    local highestScore = -1
    
    for _, player in ipairs(self.players) do
        if player.score > highestScore then
            highestScore = player.score
            winner = player
        end
    end
    
    return winner
end

function GameManager:handleMouseMoved(x, y)
    if self.state ~= "playing" then
        return
    end
    
    -- Update hover state for deck
    if self.deck then
        self.deck:setHovered(self.deck:isPointInside(x, y))
    end
    
    -- Update hover states for current player's cards
    local currentPlayer = self:getCurrentPlayer()
    if currentPlayer then
        currentPlayer:updateCardHoverStates(x, y)
    end
end

function GameManager:handleMousePressed(x, y, button)
    if self.state == "menu" then
        return
    elseif self.state == "gameover" then
        return
    elseif self.state ~= "playing" then
        return
    end
    
    if button == 1 then
        -- Check if deck was clicked
        if self.deck and self.deck:isPointInside(x, y) then
            local currentPlayer = self:getCurrentPlayer()
            if currentPlayer then
                self:drawCardForPlayer(currentPlayer)
            end
            return
        end
        
        -- Let current player handle card dragging
        local currentPlayer = self:getCurrentPlayer()
        if currentPlayer and not currentPlayer.isAI then
            currentPlayer:startDraggingCard(x, y)
        end
    end
end

function GameManager:handleMouseReleased(x, y, button)
    if self.state ~= "playing" then
        return
    end
    
    if button == 1 then
        local currentPlayer = self:getCurrentPlayer()
        if currentPlayer and currentPlayer.draggedCard then
            currentPlayer:stopDraggingCard()
        end
    end
end

function GameManager:handleKeyPressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        if self.state == "menu" then
            self:setupGame(1)
        elseif self.state == "playing" then
            self:nextTurn()
        end
    elseif key == "r" then
        if self.state == "gameover" then
            self.state = "menu"
            self.turn = 1
            self.currentPlayerIndex = 1
            self.players = {}
        end
    elseif key == "1" or key == "2" or key == "3" or key == "4" then
        if self.state == "menu" then
            local numPlayers = tonumber(key)
            self:setupGame(numPlayers)
        end
    end
end

function GameManager:getState()
    return self.state
end

function GameManager:setState(state)
    self.state = state
end

return GameManager

