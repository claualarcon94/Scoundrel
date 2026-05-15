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
local stash        -- Escenario guardado: { drawnCards, handCards, tempDiscard, lifepoints } o nil
local lifepoints = 20  -- Vida del jugador
local refilling    -- true mientras se rellena drawnCards desde el deck

-- Botones: posición y tamaño
local btnX, btnY, btnW, btnH = 600, 140, 80, 40
local btn2Y = btnY + btnH + 5   -- Botón calabozo, mismo X, debajo del reinicio
local btn3Y = btn2Y + btnH + 5  -- Botón rellenar, mismo X, debajo del calabozo
local scoopX, scoopY, scoopW, scoopH = 325, 60, 80, 25  -- Botón scoop, entre cartas 2 y 3 de drawnCards

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
	-- Si hay tempDiscard en stash, mostrarlo sobre el descarte base
	if stash and #stash.tempDiscard > 0 then
		local top = stash.tempDiscard[#stash.tempDiscard]
		top.x = 50
		top.y = 250
		top:draw()
	end
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

	-- Botón scoop (naranjo, arriba de drawnCards entre cartas 2 y 3)
	love.graphics.setColor(0.9, 0.5, 0.1)
	love.graphics.rectangle("fill", scoopX, scoopY, scoopW, scoopH)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", scoopX, scoopY, scoopW, scoopH)
	love.graphics.print("Scoop", scoopX + 16, scoopY + 5)
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
		local sDrawnStr = ""
		for i, c in ipairs(stash.drawnCards) do
			sDrawnStr = sDrawnStr .. (i > 1 and ", " or "") .. cardStr(c)
		end
		local sHandStr = ""
		for i, c in ipairs(stash.handCards) do
			sHandStr = sHandStr .. (i > 1 and ", " or "") .. cardStr(c)
		end
		local sTempStr = ""
		for i, c in ipairs(stash.tempDiscard) do
			sTempStr = sTempStr .. (i > 1 and ", " or "") .. cardStr(c)
		end
		print("Calabozo guardado (vida:" .. stash.lifepoints .. ")")
		print("  drawn: " .. sDrawnStr)
		print("  mano:  " .. sHandStr)
		print("  temp:  " .. sTempStr)
	end
	print("refilling: " .. tostring(refilling))
	print()
end

-- Guarda (o reemplaza) el escenario actual: drawnCards, mano y vida
function saveScenario()
	stash = { drawnCards = {}, handCards = {}, tempDiscard = {}, lifepoints = lifepoints }
	for _, card in ipairs(drawnCards.cards) do
		table.insert(stash.drawnCards, card)
	end
	for _, card in ipairs(playerHand.cards) do
		table.insert(stash.handCards, card)
	end
	print("--- Escenario guardado (robadas:" .. #stash.drawnCards .. " mano:" .. #stash.handCards .. " vida:" .. stash.lifepoints .. ") ---")
end

function love.mousepressed(x, y, button)
	-- Click izquierdo sobre el mazo => robar la primera carta
	if deck:containsPoint(x, y) then
		if button == 1 and not deck:isEmpty() then
			if not drawnCards:isFull() and (refilling or drawnCards:count() < 2) then
				refilling = true
				drawnCards:addCard(deck:drawCard())
				saveScenario()
				if drawnCards:isFull() or deck:isEmpty() then
					refilling = false
				end
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
		refilling = false
		printState()
		return
	end

	-- Click en botón reinicio calabozo => restaurar escenario guardado
	if stash and x >= btnX and x <= btnX + btnW and y >= btn2Y and y <= btn2Y + btnH then
		-- Remover del descarte las cartas que fueron descartadas en este escenario
		for _, sCard in ipairs(stash.tempDiscard) do
			for i = #discard.cards, 1, -1 do
				if discard.cards[i] == sCard then
					table.remove(discard.cards, i)
					break
				end
			end
		end
		-- Restaurar drawnCards y mano desde las copias del stash
		drawnCards.cards = {}
		for _, card in ipairs(stash.drawnCards) do
			table.insert(drawnCards.cards, card)
		end
		playerHand.cards = {}
		for _, card in ipairs(stash.handCards) do
			table.insert(playerHand.cards, card)
		end
		stash.tempDiscard = {}
		lifepoints = stash.lifepoints
		refilling = false
		printState()
		return
	end

	-- Click en botón rellenar => llenar drawnCards desde el deck
	if button == 1 and x >= btnX and x <= btnX + btnW and y >= btn3Y and y <= btn3Y + btnH then
		if #drawnCards.cards < 2 or refilling then
			refilling = true
			while not drawnCards:isFull() and not deck:isEmpty() do
				drawnCards:addCard(deck:drawCard())
			end
			if drawnCards:isFull() or deck:isEmpty() then
				refilling = false
			end
			saveScenario()
			printState()
		end
		return
	end

	-- Click en botón scoop => barajar drawnCards y enviarlas al fondo del mazo
	if button == 1 and x >= scoopX and x <= scoopX + scoopW and y >= scoopY and y <= scoopY + scoopH then
		if #drawnCards.cards > 0 then
			-- Barajar las cartas de drawnCards
			for i = #drawnCards.cards, 2, -1 do
				local j = math.random(i)
				drawnCards.cards[i], drawnCards.cards[j] = drawnCards.cards[j], drawnCards.cards[i]
			end
			-- Enviarlas al final del mazo
			for _, card in ipairs(drawnCards.cards) do
				table.insert(deck.cards, card)
			end
			drawnCards.cards = {}
			stash = nil
			printState()
		end
		return
	end

	-- Click sobre una carta robada
	local idx = drawnCards:getCardAt(x, y)
	if idx then
		-- Bloqueado si se está rellenando, o si es la última carta y aún hay mazo
		if (refilling and drawnCards:count() < 4) or (deck:count() > 0 and drawnCards:count() == 1) then
			return
		end

		local card = drawnCards.cards[idx]

		-- Click derecho sobre Espadas o Tréboles => descarte directo y daño
		if button == 2 then
			if card.suit == "Espadas" or card.suit == "Treboles" then
				drawnCards:removeCard(idx)
				discard:addCard(card)
				if stash then table.insert(stash.tempDiscard, card) end
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
				if stash then table.insert(stash.tempDiscard, card) end
			elseif card.suit == "Diamantes" then
				-- Rule 5: si ya hay diamante, todo al descarte
				for i = #playerHand.cards, 1, -1 do
					if playerHand.cards[i].suit == "Diamantes" then
						for _, c in ipairs(playerHand.cards) do
							discard:addCard(c)
							if stash then table.insert(stash.tempDiscard, c) end
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
