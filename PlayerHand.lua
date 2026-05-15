-- Entidad Mano del Jugador
PlayerHand = {}
PlayerHand.__index = PlayerHand

function PlayerHand:new(x, y)
	local hand = {}
	setmetatable(hand, PlayerHand)
	hand.x = x
	hand.y = y
	hand.cards = {}
	hand.offsetX = 30
	return hand
end

function PlayerHand:addCard(card)
	table.insert(self.cards, card)
end

function PlayerHand:removeCard(index)
	return table.remove(self.cards, index)
end

function PlayerHand:count()
	return #self.cards
end

function PlayerHand:containsPoint(px, py)
	for i = #self.cards, 1, -1 do
		local card = self.cards[i]
		if px >= card.x and px <= card.x + 80 and py >= card.y and py <= card.y + 120 then
			return i
		end
	end
	return nil
end

function PlayerHand:draw()
	for i, card in ipairs(self.cards) do
		card.x = self.x + (i - 1) * self.offsetX
		card.y = self.y
		card:draw()
	end
end
