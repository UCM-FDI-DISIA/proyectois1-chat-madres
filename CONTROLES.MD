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

* Colocar fichas del atril en el tablero: seleccionar una a una las fichas de la siguiente forma:
  - OPCION 1: Hacer click en la ficha a desplazar y la casilla desdeada.
  - OPCION 2: Con el cursor sobre la ficha a desplazar mantener pulsado hasta la casilla deseada.
  - OPCION 3 (teclado): Seleccionar 1-7 la ficha a desplazar y utilizar teclas Up, Down, Left, Right hasta llegar a la posición deseada y pulsar ENTER para confirmar.
   (*) si en algun momento se desea cancelar la colocación pulsar ESC.

* Terminar la colocación / pasar turno: pulsar en el botón _Finalizar colocación_.

* Intercambiar fichas con la bolsa: pulsar el botón _Intercambiar fichas_ y hacer click una por una. Tras comprobar que todas todas las que se desea intercambiar cambiar están iluminadas pulsar ENTER.

* Reordenar fichas: pulsar botón _Reordenar fichas_ y hacer click en dos fichas para que intercambien posiciones en el atril.

* Mostrar información de ficha (letra / puntuación): mantener el ratón sobre la ficha del atril.

---

## Interfaz y botones principales (UI)

- Atril: muestra las fichas del jugador y su puntuación parcial.
- Tablero: casillas con multiplicadores (DL, TL, DW, TW) claramente marcadas.
- Panel de acciones:
   - "Finalizar Turno"
   - "Cancelar Colocación" 
   - "Intercambiar Fichas"
   - "Reordenar Fichas"
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
