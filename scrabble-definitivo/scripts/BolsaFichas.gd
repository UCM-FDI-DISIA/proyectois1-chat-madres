extends Node
class_name BolsaFichas

# =======================================================
# CONFIGURACIÓN: letras, puntuaciones y cantidades
# =======================================================
const FICHAS_DATOS = {
	"J": {"puntos": 8, "cantidad": 1},
	"LL": {"puntos": 8, "cantidad": 1},
	"Ñ": {"puntos": 8, "cantidad": 1},
	"RR": {"puntos": 8, "cantidad": 1},
	"X": {"puntos": 8, "cantidad": 1},
	"Z": {"puntos": 10, "cantidad": 1},
	"A": {"puntos": 1, "cantidad": 12},
	"E": {"puntos": 1, "cantidad": 12},
	"I": {"puntos": 1, "cantidad": 6},
	"O": {"puntos": 1, "cantidad": 9},
	"U": {"puntos": 1, "cantidad": 5},
	"L": {"puntos": 1, "cantidad": 4},
	"N": {"puntos": 1, "cantidad": 5},
	"R": {"puntos": 1, "cantidad": 5},
	"S": {"puntos": 1, "cantidad": 6},
	"D": {"puntos": 2, "cantidad": 5},
	"G": {"puntos": 2, "cantidad": 2},
	"T": {"puntos": 1, "cantidad": 4},
	"B": {"puntos": 3, "cantidad": 2},
	"C": {"puntos": 3, "cantidad": 4},
	"M": {"puntos": 3, "cantidad": 2},
	"P": {"puntos": 3, "cantidad": 2},
	"F": {"puntos": 4, "cantidad": 1},
	"H": {"puntos": 4, "cantidad": 2},
	"V": {"puntos": 4, "cantidad": 1},
	"Y": {"puntos": 4, "cantidad": 1},
	"CH": {"puntos": 5, "cantidad": 1},
	"Q": {"puntos": 5, "cantidad": 1},
	" ": {"puntos": 0, "cantidad": 2}  # comodines
}

# Carpeta donde están las imágenes
const ICONS_PATH = "res://Casillas/Fichas"

var bolsa: Array = []  # contendrá objetos tipo {letra, puntos, textura}

func _ready() -> void:
	_inicializar_bolsa()

func _inicializar_bolsa() -> void:
	bolsa.clear()
	for letra in FICHAS_DATOS.keys():
		var datos = FICHAS_DATOS[letra]
		for i in range(datos.cantidad):
			var tex := load(ICONS_PATH.path_join("%s.png" % letra))
			if tex == null:
				push_warning("⚠️ No se encontró textura para '%s'" % letra)
			bolsa.append({
				"letra": letra,
				"puntos": datos.puntos,
				"texture": tex
			})
	bolsa.shuffle()

func sacar_fichas(cantidad: int) -> Array:
	var fichas: Array = []
	for i in range(cantidad):
		if bolsa.is_empty():
			break
		fichas.append(bolsa.pop_back())
	return fichas

func devolver_fichas(fichas: Array) -> void:
	for f in fichas:
		bolsa.append(f)
	bolsa.shuffle()

func quedan() -> int:
	return bolsa.size()
