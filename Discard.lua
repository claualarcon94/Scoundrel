-- Clase Descarte
Discard = {}
Discard.__index = Discard

function Discard:new(x, y)
	local d = {}
	setmetatable(d, Discard)
	d.x = x
	d.y = y
	d.cards = {}
	return d
end

function Discard:addCard(card)
	table.insert(self.cards, card)
end

function Discard:count()
	return #self.cards
end

function Discard:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", self.x, self.y, 80, 120)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle("line", self.x, self.y, 80, 120)
	love.graphics.print("Descarte", self.x + 5, self.y + 50)

	if #self.cards > 0 then
		local top = self.cards[#self.cards]
		top.x = self.x
		top.y = self.y
		top:draw()
	end
end
