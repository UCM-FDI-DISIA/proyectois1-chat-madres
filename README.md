# Proyecto Scrabble
# Introducción

Este repositorio tiene como propósito desarrollar una versión digital del juego de mesa Scrabble.  
El objetivo es ofrecer una experiencia sencilla y funcional que permita jugar partidas entre varias personas desde una interfaz digital.  

Este archivo README sirve como guía inicial y resumen de la información más importante.  
Para documentación más detallada, se puede consultar la **Wiki del proyecto**:

[Ir a la Wiki](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki)

---

## Vista previa del juego
[![Pantalla Inicial](https://github.com/user-attachments/assets/6e051395-1876-49a4-b51e-d4d6dcb8ce73)](https://github.com/user-attachments/assets/6e051395-1876-49a4-b51e-d4d6dcb8ce73)

[![Tablero y Fichas](https://github.com/user-attachments/assets/038b8258-9ceb-4d60-a2c2-8f9065a47fac)](https://github.com/user-attachments/assets/038b8258-9ceb-4d60-a2c2-8f9065a47fac)


## Índice

- [Objetivos](#objetivos)
- [Historias de usuario](#historias-de-usuario)
- [Gestión de riesgos](#gestion-de-riesgos)
- [Estructura inicial](#estructura-inicial)
- [Sprint](#sprint)
- [Próximos pasos](#proximos-pasos)
- [Enlaces útiles](#enlaces-utiles)

---

## Objetivos

- Crear una versión digital y funcional del juego Scrabble.  
- Permitir partidas entre 2 y 4 jugadores.  
- Mostrar el tablero, las fichas y la puntuación de manera clara.  
- Validar jugadas automáticamente para asegurar que se cumplan las reglas.  
- Mantener un registro de riesgos y tareas para facilitar la colaboración.

Más información en la sección correspondiente de la Wiki:  
[Ver objetivos en la Wiki](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki#objetivos)

---

## Historias de usuario

Las historias de usuario describen las funcionalidades del sistema desde el punto de vista del jugador.  
Algunas de las funcionalidades principales son:

- Leer las instrucciones del juego y poder omitirlas si ya se conocen.  
- Colocar palabras válidas en el tablero y obtener puntos.  
- Validar automáticamente las jugadas antes de confirmarlas.  
- Ver el tablero y la puntuación en tiempo real.  
- Pasar turno y finalizar la partida de acuerdo con las reglas establecidas.

La lista completa y detallada se encuentra en el apartado Issues:  
[Ver historias de usuario](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/issues)

---

## Gestión de riesgos

El proyecto cuenta con un plan de gestión de riesgos basado en la priorización de Boehm.  
Esto permite identificar, evaluar y mitigar problemas antes de que afecten al desarrollo.

- Los riesgos se clasifican en técnicos, organizativos, humanos, herramientas y globales.  
- Cada riesgo cuenta con una probabilidad, severidad, nivel y plan de mitigación.  
- Los riesgos se revisan periódicamente.

La tabla completa de riesgos está documentada en la Wiki:  
[Ver gestión de riesgos](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki#gesti%C3%B3n-de-riesgos)

---

## Estructura 

Actualmente el repositorio cuenta con:

- `README.md`: información general y enlaces principales.
- `CONTROLES.MD´: información para el usuario acerca de los controles y jugabilidad.  
- Wiki: documentación funcional (historias de usuario y gestión de riesgos).  
- Issues y Project Board: seguimiento de tareas y prioridades.

Conforme avance el desarrollo, se agregarán instrucciones de instalación, arquitectura del sistema y guías de contribución.  
[Ver estructura en la Wiki](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki#estructura)

---

## Sprint

El proyecto se ha desarrollado en 5 sprints y un sprint inicial (el cual se dedicó a la elección del tipo de juego, a la creación de historias de usuario y a la planifiación inicial) cada uno de dos semanas.

Durante los sprints se han implementado:

- **Sprint 1:** Planificación del proyecto. Elección de objetivos, elaboración de historias de usuario y toma de decisiones como el motor de desarrollo.
- **Sprint 2:** Creación de las bases. Diseño del tablero, fichas y pantalla de turno.
- **Sprint 3:** Tareas esenciales. Implementación de colocación de fichas y validación de palabras y establecimiento de la lógica de turno.
- **Sprint 4:** Multijugador. Desarrollo del sistema multijugador, lógica de turnos y cálculos de puntuación por jugador.
- **Sprint 5:** Mejoras. Corrección de errores, mejoras visuales y adición de pequeñas funcionalidades.

Los sprints se completaron según la planificación del backlog.
[Ver Sprint](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki#sprint)

---

## Estado final del proyecto

La versión actual del juego es totalmente funcional.

Incluye:
- Tablero de 15x15 completamente operativo.  
- Sistema de colocar fichas en las casillas (con ratón o con teclado).
- Validación automática de palabras.  
- Cálculo de puntuación según las reglas oficiales.  
- Gestión de turnos entre 2 y 4 jugadores.  
- Pantalla inicial, pantalla de fin, pantalla de carga y diseño visual completo.  
- Flujo de partida desde inicio hasta final.

El juego está listo para ser presentado y utilizado como prototipo funcional.

[Ver planificación en la Wiki](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki)

---

## Enlaces útiles
- [Wiki principal](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki)  
- [Historias de usuario](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/issues)  
- [Gestión de riesgos](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki#gesti%C3%B3n-de-riesgos)  
- [Sprint](https://github.com/UCM-FDI-DISIA/proyectois1-chat-madres/wiki#sprint)  
- [Project Backlog](https://github.com/orgs/UCM-FDI-DISIA/projects/157)
  
---

## Importar proyecto en Godot
1. Abrir Godot (Godot_v4.5-stable_win64.exe)
2. Seleccionar la opción de importar proyecto.
3. Seleccionar la carpeta de GitHub.
4. Seleccionar el repositorio proyectois1-chat-madres.
5. Seleccionar la carpeta Scrabble_definitivo.

---

## Ejecutar el proyecto
1. Abrir el proyecto en Godot siguiendo los pasos anteriores.
2. Abrir la escena principal preferiblemente:
   `Menuprincipal.tscn`. (si la buscas en el buscador tener en cuenta la tilde)
4. Pulsar F5 o hacer clic en Run Project.

## Tecnologías utilizadas
- Godot Engine 4.5
- GDScript
- GitHub Projects (gestión de tareas)
- Diccionario RAE (para validación de palabras)
