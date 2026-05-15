-- Clase Carta: representa una carta individual con valor, palo y posición
Card = {}
Card.__index = Card

-- Constructor: crea una carta en (x, y) con un valor numérico (2-14) y un palo
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

-- Conversión de valor numérico a nombre visible en pantalla
local displayNames = { [14] = "As", [11] = "J", [12] = "Q", [13] = "K" }

-- Palos que se dibujan en rojo (Diamantes y Corazones)
local displayColors = {
	["Diamantes"] = { 1, 0, 0 },
	["Corazones"] = { 1, 0, 0 },
}

-- Fuentes: bold para el valor, normal para el palo
local boldFont
local regularFont

function Card:draw()
	-- Inicializar fuentes solo la primera vez (lazy init)
	if not boldFont then
		boldFont = love.graphics.newFont(24)
		regularFont = love.graphics.newFont(12)
	end

	-- Relleno blanco de la carta (dibujar antes que el borde)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	-- Borde negro
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

	-- Elegir color según el palo (rojo para Corazones/Diamantes, negro para el resto)
	local color = displayColors[self.suit] or { 0, 0, 0 }
	love.graphics.setColor(color)

	-- Valor en bold arriba a la izquierda
	love.graphics.setFont(boldFont)
	local display = displayNames[self.value] or tostring(self.value)
	love.graphics.print(display, self.x + 10, self.y + 10)

	-- Palo en fuente normal abajo a la izquierda
	love.graphics.setFont(regularFont)
	love.graphics.print(self.suit, self.x + 10, self.y + 90)
end
