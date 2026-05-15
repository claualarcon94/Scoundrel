# Scoundrel

Implementación en Lua + LÖVE2D del juego de cartas **Scoundrel** (Oron N., Free Press, 2000).

## Requisitos

- [LÖVE2D](https://love2d.org/) 11.x

## Cómo jugar

```bash
love .
```

### Objetivo

Sobrevivir el mayor número de rondas posible. El mazo tiene 52 cartas (4 palos x 13 valores). Se roban hasta 4 cartas visibles a la vez, y se debe jugar una carta por turno.

### Reglas

1. **Mano vacía** — Solo se puede tomar un Diamante a la mano si está vacía.
2. **Espadas y Tréboles** — Click derecho las descarta directamente y resta su valor a la vida.
3. **Espadas y Tréboles a la mano** — Requieren un Diamante en la mano. Si la última carta en mano es Espada/Trébol, la nueva no puede superar su valor.
4. **Daño por armas** — Al tomar una Espada/Trébol a la mano, si el Diamante que la habilita tiene menor valor, la diferencia se resta de la vida.
5. **Segundo Diamante** — Si ya hay un Diamante en la mano y se toma otro, toda la mano actual se descarta y solo queda el nuevo Diamante.
6. **Corazones** — Curan su valor (máx. 20) y van directo al descarte.

### Controles

| Acción | Descripción |
|---|---|
| **Click izquierdo en mazo** | Robar una carta (se rellena hasta 4) |
| **Click izquierdo en carta robada** | Tomar a la mano o descartar (Corazones) |
| **Click derecho en carta robada** | Descarte directo (solo Espadas/Tréboles) |
| **Botón Reinicio** | Reinicia la partida desde cero |
| **Botón Calabozo** | Restaura el último escenario guardado |
| **Botón Rellenar** | Llena drawnCards desde el mazo en una acción |
| **Botón Scoop** | Baraja drawnCards y las manda al fondo del mazo |

## Estructura del proyecto

```
├── main.lua          -- Bucle principal, reglas, botones, entrada del mouse
├── Card.lua          -- Clase Carta (valor, palo, render)
├── Deck.lua          -- Clase Mazo (52 cartas, barajar, robar)
├── DrawnCards.lua    -- Clase Cartas Robadas (hasta 4 visibles)
├── Discard.lua       -- Clase Descarte (pila de descartes)
└── PlayerHand.lua    -- Clase Mano del Jugador (cartas superpuestas)
```

## Créditos

Basado en el juego de cartas **Scoundrel** creado por Oron N. y publicado en *Free Press* (2000).
