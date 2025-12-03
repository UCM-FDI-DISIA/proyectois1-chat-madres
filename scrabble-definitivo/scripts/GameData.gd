extends Node

# Contador de partidas jugadas
var partidas_jugadas: int = 0

# Tiempo por turno en segundos
var tiempo_por_turno: float = 60.0

# Métodos disponibles
var metodo_puntuacion: String = "Clasico"  # valor por defecto
const METODOS_PUNTUACION := [
	"Clasico",
	"Bonus Palabra Larga",
	"Solo Vocales",
	"Palabra Perfecta",
	"Triple Letra Inicial",
	"Puntaje Progresivo",
    "Letra Duplicada"
]

# Número de jugadores
var num_jugadores: int = 1   # valor por defecto

# Datos globales del juego
var puntuaciones: Array = []
var jugador_actual: int = 0
var atriles_jugadores: Array = []

# Nombres de los jugadores
var player_names: Array = ["", "", "", ""]

# Inicializar puntuaciones y atriles
func inicializar_juego():
	puntuaciones = []
	atriles_jugadores = []
	for i in range(num_jugadores):
		puntuaciones.append(0)
		atriles_jugadores.append([])  # Cada jugador tendrá su atril (vacío al inicio)
		
