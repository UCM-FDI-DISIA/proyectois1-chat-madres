extends PanelContainer

@export var cantidad_fichas_en_atril: int = 7
@onready var bolsa: BolsaFichas = preload("res://scripts/BolsaFichas.gd").new()

var huecos: Array[Button] = []
var fichas_en_atril: Array = []

var modo_intercambio: bool = false			# 🔹 NUEVO: controla si estamos eligiendo fichas para intercambio
var seleccionadas_para_intercambio: Array[Button] = []	# 🔹 NUEVO: fichas seleccionadas

func _ready() -> void:
	if bolsa.bolsa.is_empty():
		bolsa._inicializar_bolsa()

	var grid: GridContainer = $VBoxContainer/Panel/GridContainer
	for child in grid.get_children():
		if child is Button and child.name.begins_with("Hueco"):
			huecos.append(child)
			# 🔹 Asignar el manager si el script del botón lo define
			if "manager" in child:
				child.manager = self


	_rellenar_atril()

# =======================================================
# FUNCIONES PRINCIPALES
# =======================================================

func _rellenar_atril() -> void:
	var nuevas_fichas: Array = bolsa.sacar_fichas(cantidad_fichas_en_atril)
	fichas_en_atril = nuevas_fichas.duplicate()

	for i in range(huecos.size()):
		var b: Button = huecos[i]
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = Vector2(40, 40)

		if i < nuevas_fichas.size():
			var f: Dictionary = nuevas_fichas[i] as Dictionary
			var tex: Texture2D = f.get("texture", null)
			var letra: String = str(f.get("letra", ""))
			var puntos: int = int(f.get("puntos", 0))
			b.icon = tex
			b.text = ""
			b.tooltip_text = "Letra: %s\nPuntos: %d" % [letra, puntos]
			b.set_meta("letra", letra)
			b.disabled = false
		else:
			b.icon = null
			b.text = ""
			b.tooltip_text = ""
			b.disabled = false

# =======================================================
# CONTROL ATRIL / TURNO
# =======================================================

func vaciar_hueco(boton: Button) -> void:
	if boton == null:
		return
	boton.icon = null
	boton.text = ""
	boton.tooltip_text = ""
	boton.disabled = false

func reponer_fichas_colocadas() -> void:
	var vacios: Array[Button] = []
	for b in huecos:
		if b.icon == null:
			vacios.append(b)
	if vacios.is_empty():
		return
	var nuevas: Array = bolsa.sacar_fichas(vacios.size())
	for i in range(min(vacios.size(), nuevas.size())):
		var b: Button = vacios[i]
		var f: Dictionary = nuevas[i]
		b.icon = f["texture"]
		b.text = ""
		b.tooltip_text = "Letra: %s\nPuntos: %d" % [f["letra"], f["puntos"]]
		b.set_meta("letra", f["letra"])
		b.disabled = false

# =======================================================
# MODO INTERCAMBIO
# =======================================================

func seleccionar_fichas_para_intercambio() -> Array:
	print("🟡 Modo intercambio: haz clic en las fichas que deseas cambiar y pulsa ENTER para confirmar.")
	modo_intercambio = true
	seleccionadas_para_intercambio.clear()

	await _esperar_confirmacion_enter()

	modo_intercambio = false
	var seleccionadas := seleccionadas_para_intercambio.duplicate()
	# Limpiar color
	for b in huecos:
		b.modulate = Color(1, 1, 1, 1)
	return seleccionadas

func registrar_click_intercambio(boton: Button) -> void:
	if not modo_intercambio:
		return
	if boton in seleccionadas_para_intercambio:
		seleccionadas_para_intercambio.erase(boton)
		boton.modulate = Color(1, 1, 1, 1)
	else:
		seleccionadas_para_intercambio.append(boton)
		boton.modulate = Color(1, 0.6, 0.6, 1)

func _esperar_confirmacion_enter() -> void:
	await get_tree().create_timer(0.1).timeout
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			break

func intercambiar_fichas(botones: Array[Button]) -> void:
	if botones.is_empty():
		print("⚠️ No seleccionaste fichas para intercambiar.")
		return
	if bolsa.quedan() < 7:
		print("⚠️ No puedes intercambiar: quedan menos de 7 fichas en la bolsa.")
		return

	var fichas_devueltas: Array = []

	for b in botones:
		if b.icon == null or not b.has_meta("letra"):
			continue
		var letra: String = str(b.get_meta("letra"))
		var tex: Texture2D = b.icon
		var puntos: int = 0
		for f in fichas_en_atril:
			if f.has("letra") and f["letra"] == letra:
				puntos = f["puntos"]
				break
		fichas_devueltas.append({
			"letra": letra,
			"puntos": puntos,
			"texture": tex
		})
		b.icon = null
		b.text = ""
		b.tooltip_text = ""
		b.modulate = Color(1, 1, 1, 1)

	bolsa.devolver_fichas(fichas_devueltas)

	var nuevas: Array = bolsa.sacar_fichas(botones.size())
	for i in range(botones.size()):
		var b: Button = botones[i]
		if i >= nuevas.size():
			continue
		var f: Dictionary = nuevas[i]
		b.icon = f["texture"]
		b.text = ""
		b.tooltip_text = "Letra: %s\nPuntos: %d" % [f["letra"], f["puntos"]]
		b.set_meta("letra", f["letra"])

	print("✅ Intercambio completado: %d fichas nuevas." % botones.size())
