require("card")
require("deck")
require("drawncards")
require("discard")
require("playerhand")

-- Mazo, cartas robadas, descarte y mano del jugador
local deck
local drawnCards
local discard
local playerHand

function love.load()
	math.randomseed(os.time())

	deck = Deck:new(50, 100)
	drawnCards = DrawnCards:new(50, 100, 110)
	discard = Discard:new(50, 250)
	playerHand = PlayerHand:new(160, 250)

	printState()
end

function love.draw()
	love.graphics.clear(0.5, 0.5, 0.5)

	deck:draw()
	discard:draw()
	drawnCards:draw()
	playerHand:draw()
end

-- Imprime el estado actual en consola
function printState()
	local displayNames = { [14]="As", [11]="J", [12]="Q", [13]="K" }
	local function cardStr(c)
		return (displayNames[c.value] or c.value) .. " " .. c.suit
	end

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

	print("--- Estado ---")
	print("Mazo (" .. deck:count() .. "): " .. deckStr)
	print("Robadas (" .. drawnCards:count() .. "): " .. drawnStr)
	print("Descarte (" .. discard:count() .. "): " .. discardStr)
	print("Mano (" .. playerHand:count() .. "): " .. handStr)
	print()
end

function love.mousepressed(x, y, button)
	if button == 1 then
		-- Click izquierdo sobre el mazo => robar carta
		if deck:containsPoint(x, y) then
			if not deck:isEmpty() and not drawnCards:isFull() then
				drawnCards:addCard(deck:drawCard())
				printState()
			end
			return
		end

		-- Click sobre una carta robada
		local idx = drawnCards:getCardAt(x, y)
		if idx then
			local card = drawnCards:removeCard(idx)
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
