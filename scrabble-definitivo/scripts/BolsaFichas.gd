extends Node
class_name BolsaFichas

# =======================================================
# CONFIGURACIÓN: letras, puntuaciones y cantidades
# (Usamos "NULL" para la imagen, "*" internamente)
# =======================================================

const FICHAS_DATOS := {
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
	"NULL": {"puntos": 0, "cantidad": 2}  # comodines visuales (NULL.png)
}

# Carpeta donde están las imágenes
const ICONS_PATH := "res://Casillas/Fichas"

# La bolsa será una array de diccionarios:
# { "letra": STR, "puntos": INT, "texture": Texture2D }
var bolsa: Array = []


func _ready() -> void:
	_inicializar_bolsa()


# =======================================================
# Construcción real de la bolsa
# =======================================================
func _inicializar_bolsa() -> void:
	bolsa.clear()

	for clave in FICHAS_DATOS.keys():
		var datos: Dictionary = FICHAS_DATOS[clave]

		for i in range(datos["cantidad"]):

			# --- Cargar textura PNG según nombre original ---
			var tex_path := ICONS_PATH.path_join("%s.png" % clave)
			var tex := load(tex_path)

			if tex == null:
				push_warning("⚠️ No se encontró textura para '%s' (%s)" % [clave, tex_path])

			# --- Convertimos "NULL" internamente en "*" ---
			var letra_real: String = clave
			if clave == "NULL":
				letra_real = "*"   # ← comodín interno real

			# --- Añadir ficha completa ---
			bolsa.append({
				"letra": letra_real,
				"puntos": datos["puntos"],
				"texture": tex
			})

	bolsa.shuffle()


# =======================================================
# Robar fichas
# =======================================================
func sacar_fichas(cantidad: int) -> Array:
	var fichas: Array = []

	for i in range(cantidad):
		if bolsa.is_empty():
			break
		fichas.append(bolsa.pop_back())

	return fichas


# =======================================================
# Devolver fichas a la bolsa
# =======================================================
func devolver_fichas(fichas: Array) -> void:
	for f in fichas:
		bolsa.append(f)
	bolsa.shuffle()


# =======================================================
# Cuántas quedan
# =======================================================
func quedan() -> int:
	return bolsa.size()
	
# =======================================================
# Crear una ficha a partir de una letra (para recargar atriles)
# =======================================================
func crear_ficha_por_letra(letra: String) -> Dictionary:
	# Mapeo interno: el comodín "*" usa la clave "NULL" y textura NULL.png
	var clave := letra
	if letra == "*":
		clave = "NULL"

	# Datos base de la letra (puntos y cantidad)
	if not FICHAS_DATOS.has(clave):
		# Letra desconocida -> ficha sin textura y 0 puntos (defensivo)
		return {
			"letra": letra,
			"puntos": 0,
			"texture": null,
		}

	var datos: Dictionary = FICHAS_DATOS[clave]

	# Cargar textura correspondiente
	var tex_path := ICONS_PATH.path_join("%s.png" % clave)
	var tex := load(tex_path)
	if tex == null:
		push_warning("⚠️ crear_ficha_por_letra: no se encontró textura para '%s' (%s)" % [clave, tex_path])

	return {
		"letra": letra,                # usamos la letra lógica ("*", "A", "B", …)
		"puntos": int(datos["puntos"]),
		"texture": tex,
	}
