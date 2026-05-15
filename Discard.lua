-- Clase Descarte: recibe las cartas Corazones que se descartan
Discard = {}
Discard.__index = Discard

-- Constructor: posición (x, y) donde se dibuja el descarte
function Discard:new(x, y)
	local d = {}
	setmetatable(d, Discard)
	d.x = x
	d.y = y
	d.cards = {}
	return d
end

-- Agrega una carta al descarte (al final del array)
function Discard:addCard(card)
	table.insert(self.cards, card)
end

-- Cantidad de cartas en el descarte
function Discard:count()
	return #self.cards
end

-- Dibuja el descarte: rectángulo base con texto, y la última carta descartada encima
function Discard:draw()
	-- Rectángulo base del descarte
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", self.x, self.y, 80, 120)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle("line", self.x, self.y, 80, 120)
	love.graphics.print("Descarte", self.x + 5, self.y + 50)

	-- Si hay cartas, dibujar la última (la de arriba)
	if #self.cards > 0 then
		local top = self.cards[#self.cards]
		top.x = self.x
		top.y = self.y
		top:draw()
	end
end
