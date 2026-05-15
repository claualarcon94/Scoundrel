-- Clase Mazo: contiene las 52 cartas, las baraja y permite robar
Deck = {}
Deck.__index = Deck

-- Constructor: crea el mazo en (x, y), genera las cartas y las baraja
function Deck:new(x, y)
	local d = {}
	setmetatable(d, Deck)
	d.x = x
	d.y = y
	d.width = 80
	d.height = 120
	d.cards = {}
	d:_build()
	d:_shuffle()
	return d
end

-- Genera las 52 cartas (4 palos × 13 valores del 2 al 14)
function Deck:_build()
	local suits = { "Diamantes", "Espadas", "Corazones", "Treboles" }
	local values = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }
	for _, suit in ipairs(suits) do
		for _, value in ipairs(values) do
			table.insert(self.cards, Card:new(0, 0, value, suit))
		end
	end
end

-- Barajar usando el algoritmo Fisher-Yates
function Deck:_shuffle()
	for i = #self.cards, 2, -1 do
		local j = math.random(i)
		self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
	end
end

-- Saca y devuelve la primera carta del mazo (la de arriba)
function Deck:drawCard()
	return table.remove(self.cards, 1)
end

-- Cantidad de cartas restantes en el mazo
function Deck:count()
	return #self.cards
end

-- Devuelve true si el mazo está vacío
function Deck:isEmpty()
	return #self.cards == 0
end

-- Dibuja el mazo como un rectángulo blanco con borde negro y texto "Deck"
function Deck:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	love.graphics.print("Deck", self.x + 20, self.y + 50)
end

-- Devuelve true si las coordenadas (x, y) están dentro del mazo
function Deck:containsPoint(x, y)
	return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end
