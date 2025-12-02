# CONTROLES — Scrabble (Scrabble-Definitivo)

Este documento recoge los controles y acciones necesarias para jugar al Scrabble implementado en el proyecto. Está pensado para cubrir las interacciones más comunes en escritorio (ratón + teclado) y en dispositivos táctiles, así como accesibilidad y atajos. Adapta los nombres de botones/menús a los que tenga la versión final del juego si difieren.

https://www.canva.com/design/DAG6MTppx5E/ChQWBAuJGdOY983jszQWsQ/edit?utm_content=DAG6MTppx5E&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton

## Índice
- Controles generales
- Controles en PC (ratón + teclado)
- Interfaz y botones principales
- Errores comunes y soluciones rápidas

---

## Controles generales
- Objetivo de la interacción: tomar fichas del atril, colocarlas en el tablero formando palabras válidas y confirmar la jugada.
- Modo de colocación: arrastrar y soltar fichas desde el atril al tablero o seleccionar ficha + seleccionar casilla destino.
- Validación: cada jugada debe ser confirmada (botón "Finalizar Turno") para que se contabilice y termine el turno.

- Seleccionar fichas de una a una.

---

## Controles en PC (ratón + teclado)

Ratón (dispositivos celulares)
- Seleccionar ficha (atril): clic izquierdo sobre la ficha.
⦁	TECLADO: tecla (1-7) según la posición de la ficha de la letra que queramos colocar

- Arrastrar ficha al tablero: mantener clic izquierdo y arrastrar hasta la casilla deseada; soltar para colocar.
⦁	TECLADO: con las teclas (up,down,left,right) para mover la ficha a la casilla deseada; y ENTER para colocar.

- Quitar ficha colocada antes de confirmar: clic derecho sobre la ficha colocada o arrastrar de nuevo al atril.
- Mostrar información de ficha (letra / puntuación): mantener el ratón sobre la ficha cuando este en el atril.

- Confirmar jugada o pasar turno: botón "Finalizar Turno"
- Cancelar colocación actual (devolver fichas colocadas al atril): botón "Cancelar Colocación"
- Intercambiar fichas con la bolsa: botón "Intercambiar Fichas"
- Reordenar fichas en el atril: botón "Reordenar Fichas"


---

## Interfaz y botones principales (UI)

- Atril: muestra las fichas del jugador y su puntuación parcial.
- Tablero: casillas con multiplicadores (DL, TL, DW, TW) claramente marcadas.
- Panel de acciones:
   -"Finalizar Turno"
   -"Cancelar Colocación"
   -"Intercambiar Fichas"
   -"Reordenar Fichas"
- Panel lateral/infobar:
  - Puntuaciones de jugadores, turno actual, historial de jugadas.
- Indicadores:
  - Bolsa: número de fichas restantes.
  - Ficha comodín: opción para elegir letra al jugarla.

---

## Errores comunes y soluciones rápidas

- No puedo colocar fichas en el tablero:
  - Asegúrate de que el turno es tuyo.
  - Verifica que las fichas formen palabras conectadas con el tablero (primera jugada debe pasar por la casilla central).
- La jugada no se valida:
  - Comprueba la ortografía y que todas las nuevas palabras formadas sean válidas.
  - Revisa si hay fichas en posiciones ilegales (separadas).
- No aparecen sugerencias:
  - La función puede depender del diccionario cargado; revisa configuración de diccionario.
- Ficha desaparece al arrastrar:
  - Posible bug gráfico; intenta devolver la ficha con Esc o recargar la partida.

---
