-- Clase Carta
Card = {}
Card.__index = Card

function Card:new(x, y, value, suit)
	local card = {}
	setmetatable(card, Card)
	card.x = x
	card.y = y
	card.value = value
	card.suit = suit

	card.width = 80
	card.height = 120

	return card
end

-- Cómo se muestra cada valor numérico en pantalla
local displayNames = {
	[14] = "As", [11] = "J", [12] = "Q", [13] = "K"
}

function Card:draw()
	-- Borde negro
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

	-- Relleno blanco
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	-- Valor (As/J/Q/K/número) arriba a la izquierda
	love.graphics.setColor(0, 0, 0)
	local display = displayNames[self.value] or tostring(self.value)
	love.graphics.print(display, self.x+10, self.y+10)

	-- Palo abajo a la izquierda
	love.graphics.print(self.suit, self.x+10, self.y+90)
end
