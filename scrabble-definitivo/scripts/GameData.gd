extends Node

var num_jugadores: int = 1   # valor por defecto
# Autoload singleton para datos globales del juego
var puntuaciones: Array = []
var jugador_actual: int = 0

var atriles_jugadores: Array = []

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
# GameData.gd

func inicializar_juego():
	puntuaciones = []
	atriles_jugadores = []
	for i in range(num_jugadores):
		puntuaciones.append(0)
		# Cada jugador tendrá 7 fichas en su atril
		atriles_jugadores.append([])  # lista vacía que después se llena
