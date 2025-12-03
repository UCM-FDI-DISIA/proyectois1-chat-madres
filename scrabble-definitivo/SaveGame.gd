extends Node

# Archivo donde se guardan las estadísticas
const SAVE_FILE := "user://stats.json"

# Diccionario de estadísticas
var estadisticas = {
	"PartidasJugadas": 0,
	"PuntosTotales": 0,
	"AtrilVacio": 0,
	"PalabrasLargas": 0,
	"PalabraPerfecta": 0,
	"Monedas": 0
}

func _ready():
	cargar_datos()
	mostrar_estadisticas()

# Guardar estadísticas en JSON
func guardar_datos():
	var file = FileAccess.open("user://stats.json", FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify({"estadisticas": estadisticas}))
		file.close()

func cargar_datos():
	if not FileAccess.file_exists(SAVE_FILE):
		guardar_datos() # crear archivo si no existe
		return

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var data_text = file.get_as_text()
		file.close()

		var parse_result = JSON.parse_string(data_text)


# Mostrar estadísticas en consola
func mostrar_estadisticas():
	for key in estadisticas.keys():
		print("%s: %s" % [key, str(estadisticas[key])])

# Actualizar una estadística
func actualizar_estadistica(nombre: String, cantidad: int = 1):
	if estadisticas.has(nombre):
		estadisticas[nombre] += cantidad
		guardar_datos()
		mostrar_estadisticas()

# Función para sumar partidas jugadas
func sumar_partida():
	estadisticas["PartidasJugadas"] += 1
	guardar_datos()


# Función para añadir puntos
func sumar_puntos(cantidad: int):
	estadisticas["PuntosTotales"] += cantidad
	guardar_datos()

func sumar_atril_vacio():
	estadisticas["AtrilVacio"] += 1
	guardar_datos()
	print("Atril vaciado - Total: %d" % estadisticas["AtrilVacio"])
