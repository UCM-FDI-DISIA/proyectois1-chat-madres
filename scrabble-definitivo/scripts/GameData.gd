extends Node

# Tiempo por turno en segundos
var tiempo_por_turno: float = 60.0

# Número de jugadores
var num_jugadores: int = 1   # valor por defecto

# Datos globales del juego
var puntuaciones: Array = []
var jugador_actual: int = 0
var atriles_jugadores: Array = []
var puntuaciones_finales: Array = []

# Nombres de los jugadores
var player_names: Array = ["", "", "", ""]

# Inicializar puntuaciones y atriles
func inicializar_juego():
	puntuaciones = []
	atriles_jugadores = []
	for i in range(num_jugadores):
		puntuaciones.append(0)
		atriles_jugadores.append([])  # Cada jugador tendrá su atril (vacío al inicio)
