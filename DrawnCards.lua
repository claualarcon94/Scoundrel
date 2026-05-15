-- Clase Cartas Robadas: hasta 4 cartas visibles en fila horizontal
DrawnCards = {}
DrawnCards.__index = DrawnCards

-- Constructor: posición (x, y) y separación entre cartas
function DrawnCards:new(x, y, spacing)
	local dc = {}
	setmetatable(dc, DrawnCards)
	dc.x = x
	dc.y = y
	dc.spacing = spacing
	dc.cards = {}
	return dc
end

-- Agrega una carta al final del array (nueva carta robada)
function DrawnCards:addCard(card)
	table.insert(self.cards, card)
end

-- Elimina y devuelve la carta en la posición indicada
function DrawnCards:removeCard(index)
	return table.remove(self.cards, index)
end

-- Cantidad de cartas robadas actualmente
function DrawnCards:count()
	return #self.cards
end

-- Devuelve true si ya hay 4 cartas (límite máximo)
function DrawnCards:isFull()
	return #self.cards >= 4
end

-- Busca qué carta está en las coordenadas (px, py). Itera en reversa
-- para que la carta más a la derecha tenga prioridad. Devuelve el índice o nil.
function DrawnCards:getCardAt(px, py)
	for i = #self.cards, 1, -1 do
		local card = self.cards[i]
		if px >= card.x and px <= card.x + card.width and py >= card.y and py <= card.y + card.height then
			return i
		end
	end
	return nil
end

-- Dibuja todas las cartas en fila, cada una separada por self.spacing
function DrawnCards:draw()
	for i, card in ipairs(self.cards) do
		card.x = self.x + i * self.spacing
		card.y = self.y
		card:draw()
	end
end
