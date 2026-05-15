-- Clase Cartas Robadas (hasta 4 en pantalla)
DrawnCards = {}
DrawnCards.__index = DrawnCards

function DrawnCards:new(x, y, spacing)
	local dc = {}
	setmetatable(dc, DrawnCards)
	dc.x = x
	dc.y = y
	dc.spacing = spacing
	dc.cards = {}
	return dc
end

function DrawnCards:addCard(card)
	table.insert(self.cards, card)
end

function DrawnCards:removeCard(index)
	return table.remove(self.cards, index)
end

function DrawnCards:count()
	return #self.cards
end

function DrawnCards:isFull()
	return #self.cards >= 4
end

function DrawnCards:getCardAt(px, py)
	for i = #self.cards, 1, -1 do
		local card = self.cards[i]
		if px >= card.x and px <= card.x + 80 and py >= card.y and py <= card.y + 120 then
			return i
		end
	end
	return nil
end

function DrawnCards:draw()
	for i, card in ipairs(self.cards) do
		card.x = self.x + i * self.spacing
		card.y = self.y
		card:draw()
	end
end
