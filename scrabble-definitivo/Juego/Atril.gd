# atril.gd
extends PanelContainer

# ============================================================
# ATRIL DE SCRABBLE
# Muestra 7 fichas aleatorias provenientes de la BolsaFichas.
# ============================================================

@export var cantidad_fichas_en_atril: int = 7
@onready var bolsa := preload("res://scripts/BolsaFichas.gd").new()

var huecos: Array[Button] = []      # Referencias a los botones del atril
var fichas_en_atril: Array = []     # Fichas actuales (diccionarios con letra, puntos, textura)

func _ready() -> void:
	# Iniciar la bolsa si aún no se ha creado
	if bolsa.bolsa.is_empty():
		bolsa._inicializar_bolsa()

	# Obtener los huecos (botones del atril)
	var grid: GridContainer = $VBoxContainer/Panel/GridContainer
	for child in grid.get_children():
		if child is Button and child.name.begins_with("Hueco"):
			huecos.append(child)

	# Repartir las fichas iniciales
	_rellenar_atril()

# ============================================================
# FUNCIONES PRINCIPALES
# ============================================================

# Llenar el atril con fichas de la bolsa
func _rellenar_atril() -> void:
	var nuevas_fichas: Array = bolsa.sacar_fichas(cantidad_fichas_en_atril)
	fichas_en_atril = nuevas_fichas.duplicate()

	for i in range(huecos.size()):
		var b: Button = huecos[i]
		# Configuración visual base
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = Vector2(40, 40)

		if i < nuevas_fichas.size():
			var f: Dictionary = nuevas_fichas[i] as Dictionary
			# texture / letra / puntos vienen del diccionario de la bolsa
			var tex: Texture2D = f.get("texture", null)
			var letra: String = str(f.get("letra", ""))
			var puntos: int = int(f.get("puntos", 0))

			b.icon = tex
			b.text = ""  # <- NO pintamos texto encima del icono
			b.tooltip_text = "Letra: %s\nPuntos: %d" % [letra, puntos]

			# Guardamos la letra como meta (útil para el Board)
			b.set_meta("letra", letra)
			b.disabled = false
		else:
			# Hueco vacío
			b.icon = null
			b.text = ""         # <- aseguramos limpiar texto
			b.tooltip_text = ""
			b.disabled = false

# ============================================================
# FUNCIONES DE CONTROL DEL ATRIL
# ============================================================

func obtener_indice_ficha(ficha: Button) -> int:
	return huecos.find(ficha)

func abrir_hueco_en(indice: int) -> void:
	for i in range(indice + 1, huecos.size()):
		var b: Button = huecos[i]
		var t := create_tween()
		t.tween_property(b, "position:x", 60, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func restaurar_todo() -> void:
	for b in huecos:
		var t := create_tween()
		t.tween_property(b, "position:x", 0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func mover_ficha_a_hueco_1(ficha: Button) -> void:
	var grid: GridContainer = $VBoxContainer/Panel/GridContainer
	var idx := huecos.find(ficha)
	if idx == -1:
		return

	huecos.remove_at(idx)
	huecos.insert(0, ficha)

	grid.remove_child(ficha)
	grid.add_child(ficha)
	grid.move_child(ficha, 0)

# Llamado por el Board cuando “consume” un hueco (colocas la ficha en el tablero)
func vaciar_hueco(boton: Button) -> void:
	if boton == null:
		return
	boton.icon = null
	boton.text = ""          # <- limpiamos texto para que no quede la letra en blanco
	boton.tooltip_text = ""
	boton.disabled = false
