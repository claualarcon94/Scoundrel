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
local stash        -- Escenario guardado (array de cartas) o nil
local lifepoints = 20  -- Vida del jugador

-- Botones: posición y tamaño
local btnX, btnY, btnW, btnH = 600, 140, 80, 40
local btn2Y = btnY + btnH + 5   -- Botón calabozo, mismo X, debajo del reinicio
local btn3Y = btn2Y + btnH + 5  -- Botón rellenar, mismo X, debajo del calabozo

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

	-- Vida del jugador arriba del mazo
	love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(love.graphics.newFont(36))
	love.graphics.print(lifepoints, 65, 60)
    love.graphics.setFont(love.graphics.newFont(13))

	-- Dibujar todas las entidades en orden
	deck:draw()
	discard:draw()
	drawnCards:draw()
	playerHand:draw()

	-- Botón de reinicio (rojo con texto blanco)
	love.graphics.setColor(0.8, 0.2, 0.2)
	love.graphics.rectangle("fill", btnX, btnY, btnW, btnH)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", btnX, btnY, btnW, btnH)
	love.graphics.print("Reinicio", btnX + 10, btnY + 12)

	-- Botón reinicio calabozo (amarillo, debajo del rojo)
	love.graphics.setColor(0.9, 0.8, 0.1)
	love.graphics.rectangle("fill", btnX, btn2Y, btnW, btnH)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", btnX, btn2Y, btnW, btnH)
	love.graphics.print("Calabozo", btnX + 8, btn2Y + 12)

	-- Botón rellenar (azul, debajo del amarillo)
	love.graphics.setColor(0.2, 0.4, 0.9)
	love.graphics.rectangle("fill", btnX, btn3Y, btnW, btnH)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", btnX, btn3Y, btnW, btnH)
	love.graphics.print("Rellenar", btnX + 8, btn3Y + 12)
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
	if stash then
		print("Calabozo guardado (" .. #stash .. " cartas)")
	end
	print()
end

-- Guarda (o reemplaza) el escenario actual de drawnCards en el stash
function saveScenario()
	stash = {}
	for _, card in ipairs(drawnCards.cards) do
		table.insert(stash, card)
	end
	print("--- Escenario guardado (" .. #stash .. " cartas) ---")
end

function love.mousepressed(x, y, button)
	-- Click izquierdo sobre el mazo => robar la primera carta
	if deck:containsPoint(x, y) then
		if button == 1 then
			if not deck:isEmpty() and not drawnCards:isFull() then
				drawnCards:addCard(deck:drawCard())
				saveScenario()
			end
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
		stash = nil
		lifepoints = 20
		printState()
		return
	end

	-- Click en botón reinicio calabozo => restaurar escenario guardado
	if stash and x >= btnX and x <= btnX + btnW and y >= btn2Y and y <= btn2Y + btnH then
		for _, sCard in ipairs(stash) do
			for i = #discard.cards, 1, -1 do
				if discard.cards[i] == sCard then
					table.remove(discard.cards, i)
					break
				end
			end
			for i = #playerHand.cards, 1, -1 do
				if playerHand.cards[i] == sCard then
					table.remove(playerHand.cards, i)
					break
				end
			end
		end
		drawnCards.cards = {}
		for _, card in ipairs(stash) do
			table.insert(drawnCards.cards, card)
		end
		printState()
		return
	end

	-- Click en botón rellenar => llenar drawnCards desde el deck
	if button == 1 and x >= btnX and x <= btnX + btnW and y >= btn3Y and y <= btn3Y + btnH then
		if #drawnCards.cards == 0 or #drawnCards.cards == 1 then
			while not drawnCards:isFull() and not deck:isEmpty() do
				drawnCards:addCard(deck:drawCard())
			end
			saveScenario()
			printState()
		end
		return
	end

	-- Click sobre una carta robada
	local idx = drawnCards:getCardAt(x, y)
	if idx then
		-- No se puede clickear la última carta si aún quedan cartas en el mazo
		if deck:count() > 0 and drawnCards:count() == 1 then
			return
		end

		local card = drawnCards.cards[idx]

		-- Click derecho sobre Espadas o Tréboles => descarte directo y daño
		if button == 2 then
			if card.suit == "Espadas" or card.suit == "Treboles" then
				drawnCards:removeCard(idx)
				discard:addCard(card)
				lifepoints = lifepoints - card.value
				printState()
			end
			return
		end

		-- Click izquierdo
		if button == 1 then
			-- Rule 2/3: Espadas y Tréboles no pueden ir a mano sin diamante
			if card.suit == "Espadas" or card.suit == "Treboles" then
				local hasDiamond
				local diamondValue
				for _, c in ipairs(playerHand.cards) do
					if c.suit == "Diamantes" then
						hasDiamond = true
						diamondValue = c.value
						break
					end
				end
				if not hasDiamond then
					return
				end
				-- No puede superar el valor de la última carta en mano si es espada/trébol
				local lastCard = playerHand.cards[#playerHand.cards]
				if lastCard and (lastCard.suit == "Espadas" or lastCard.suit == "Treboles") then
					if card.value > lastCard.value then
						return
					end
				end
			end

			-- Remover la carta de drawnCards
			drawnCards:removeCard(idx)

			if card.suit == "Corazones" then
				-- Rule 6: curar, max 20
				lifepoints = math.min(lifepoints + card.value, 20)
				discard:addCard(card)
			elseif card.suit == "Diamantes" then
				-- Rule 5: si ya hay diamante, todo al descarte
				for i = #playerHand.cards, 1, -1 do
					if playerHand.cards[i].suit == "Diamantes" then
						for _, c in ipairs(playerHand.cards) do
							discard:addCard(c)
						end
						playerHand.cards = {}
						break
					end
				end
				playerHand:addCard(card)
			elseif card.suit == "Espadas" or card.suit == "Treboles" then
				playerHand:addCard(card)

				-- Rule 4: comparar con diamante en mano y descontar lifepoints
				for _, c in ipairs(playerHand.cards) do
					if c.suit == "Diamantes" then
						if c.value < card.value then
							lifepoints = lifepoints - (card.value - c.value)
						end
						break
					end
				end
			end
			printState()
		end
		return
	end
end
