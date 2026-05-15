-- Clase Mano del Jugador: cartas acumuladas, dibujadas solapadas
PlayerHand = {}
PlayerHand.__index = PlayerHand

-- Constructor: posición (x, y) y desplazamiento horizontal entre cartas
function PlayerHand:new(x, y)
	local hand = {}
	setmetatable(hand, PlayerHand)
	hand.x = x
	hand.y = y
	hand.cards = {}
	hand.offsetX = 30
	return hand
end

-- Agrega una carta al final de la mano
function PlayerHand:addCard(card)
	table.insert(self.cards, card)
end

-- Elimina y devuelve la carta en el índice indicado
function PlayerHand:removeCard(index)
	return table.remove(self.cards, index)
end

-- Cantidad de cartas en la mano
function PlayerHand:count()
	return #self.cards
end

-- Busca qué carta está en las coordenadas (px, py). Itera en reversa
-- para que la carta de arriba (más a la derecha) tenga prioridad.
function PlayerHand:containsPoint(px, py)
	for i = #self.cards, 1, -1 do
		local card = self.cards[i]
		if px >= card.x and px <= card.x + card.width and py >= card.y and py <= card.y + card.height then
			return i
		end
	end
	return nil
end

-- Dibuja todas las cartas de la mano solapadas horizontalmente
function PlayerHand:draw()
	for i, card in ipairs(self.cards) do
		card.x = self.x + (i - 1) * self.offsetX
		card.y = self.y
		card:draw()
	end
end
