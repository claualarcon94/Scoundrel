-- Cargar las clases del juego
require("card")
require("deck")
require("drawncards")
require("discard")
require("playerhand")

-- Referencias a las entidades del juego
local deck         -- Mazo con todas las cartas
local drawnCards   -- Cartas robadas del mazo (max 4)
local discard      -- Descarte para cartas Corazones
local playerHand   -- Mano del jugador

-- Botón de reinicio: posición y tamaño
local btnX, btnY, btnW, btnH = 600, 140, 80, 40

function love.load()
	-- Semilla aleatoria para math.random
	math.randomseed(os.time())

	-- Crear todas las entidades en sus posiciones iniciales
	deck = Deck:new(50, 100)
	drawnCards = DrawnCards:new(50, 100, 110)
	discard = Discard:new(50, 250)
	playerHand = PlayerHand:new(160, 250)

	-- Mostrar el estado inicial por consola
	printState()
end

function love.draw()
	-- Fondo gris
	love.graphics.clear(0.5, 0.5, 0.5)

	-- Dibujar todas las entidades en orden
	deck:draw()
	discard:draw()
	drawnCards:draw()
	playerHand:draw()

	-- Botón de reinicio (rectángulo rojo con texto blanco)
	love.graphics.setColor(0.8, 0.2, 0.2)
	love.graphics.rectangle("fill", btnX, btnY, btnW, btnH)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", btnX, btnY, btnW, btnH)
	love.graphics.print("Reinicio", btnX + 10, btnY + 12)
end

-- Imprime el estado actual de todas las entidades en consola
function printState()
	-- Tabla para mostrar valores especiales como texto
	local displayNames = { [14] = "As", [11] = "J", [12] = "Q", [13] = "K" }

	-- Convierte una carta a string legible
	local function cardStr(c)
		return (displayNames[c.value] or c.value) .. " " .. c.suit
	end

	-- Construir strings con todas las cartas de cada entidad
	local deckStr = ""
	for i, c in ipairs(deck.cards) do
		deckStr = deckStr .. (i > 1 and ", " or "") .. cardStr(c)
	end

	local drawnStr = ""
	for i, c in ipairs(drawnCards.cards) do
		drawnStr = drawnStr .. (i > 1 and ", " or "") .. cardStr(c)
	end

	local discardStr = ""
	for i, c in ipairs(discard.cards) do
		discardStr = discardStr .. (i > 1 and ", " or "") .. cardStr(c)
	end

	local handStr = ""
	for i, c in ipairs(playerHand.cards) do
		handStr = handStr .. (i > 1 and ", " or "") .. cardStr(c)
	end

	-- Imprimir todo
	print("--- Estado ---")
	print("Mazo (" .. deck:count() .. "): " .. deckStr)
	print("Robadas (" .. drawnCards:count() .. "): " .. drawnStr)
	print("Descarte (" .. discard:count() .. "): " .. discardStr)
	print("Mano (" .. playerHand:count() .. "): " .. handStr)
	print()
end

function love.mousepressed(x, y, button)
	if button == 1 then
		-- Click izquierdo sobre el mazo => robar la primera carta
		if deck:containsPoint(x, y) then
			if not deck:isEmpty() and not drawnCards:isFull() then
				drawnCards:addCard(deck:drawCard())
				printState()
			end
			return
		end

		-- Click en botón reinicio => recrear todo desde cero
		if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
			deck = Deck:new(50, 100)
			drawnCards = DrawnCards:new(50, 100, 110)
			discard = Discard:new(50, 250)
			playerHand = PlayerHand:new(160, 250)
			printState()
			return
		end

		-- Click sobre una carta robada
		local idx = drawnCards:getCardAt(x, y)
		if idx then
			local card = drawnCards:removeCard(idx)
			-- Corazones van al descarte, el resto a la mano
			if card.suit == "Corazones" then
				discard:addCard(card)
			else
				playerHand:addCard(card)
			end
			printState()
			return
		end
	end
end
