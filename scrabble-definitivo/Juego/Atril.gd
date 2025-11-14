extends PanelContainer

@export var cantidad_fichas_en_atril: int = 7
@onready var bolsa: BolsaFichas = preload("res://scripts/BolsaFichas.gd").new()
@onready var drag_preview_manager: Node = get_tree().current_scene.find_child("DragPreviewManager", true, false)

var huecos: Array[Button] = []
var fichas_en_atril: Array = []

# Modos
var modo_intercambio: bool = false
var modo_reordenar: bool = false

# Intercambio
var seleccionadas_para_intercambio: Array[Button] = []

# Reordenar
var ficha_reordenar_1: Button = null

func _ready() -> void:
	# Inicializar bolsa si hace falta
	if bolsa.bolsa.is_empty():
		bolsa._inicializar_bolsa()

	# Recoger huecos y asignar manager si existe la propiedad
	var grid: GridContainer = $VBoxContainer/Panel/GridContainer
	for child in grid.get_children():
		if child is Button and child.name.begins_with("Hueco"):
			huecos.append(child)
			if "manager" in child:
				child.manager = self

	_rellenar_atril()

# ----------------------------
# Relleno / Reposición
# ----------------------------
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

func vaciar_hueco(boton: Button) -> void:
	if boton == null:
		return
	boton.icon = null
	boton.text = ""
	boton.tooltip_text = ""
	boton.disabled = false

func reponer_fichas_colocadas() -> void:
	var huecos_vacios: Array[Button] = []
	for b in huecos:
		if b.icon == null:
			huecos_vacios.append(b)
	if huecos_vacios.is_empty():
		return

	var nuevas_fichas: Array = bolsa.sacar_fichas(huecos_vacios.size())

	for i in range(min(huecos_vacios.size(), nuevas_fichas.size())):
		var b: Button = huecos_vacios[i]
		var f: Dictionary = nuevas_fichas[i] as Dictionary
		var tex: Texture2D = f.get("texture", null)
		var letra: String = str(f.get("letra", ""))
		var puntos: int = int(f.get("puntos", 0))

		b.icon = tex
		b.text = ""
		b.tooltip_text = "Letra: %s\nPuntos: %d" % [letra, puntos]
		b.set_meta("letra", letra)
		b.disabled = false

# ----------------------------
# INTERCAMBIAR FICHAS
# ----------------------------
func intercambiar_fichas(botones: Array[Button]) -> void:
	if botones.is_empty():
		print("⚠️ No seleccionaste fichas para intercambiar.")
		return
	# Regla: al menos 7 en bolsa para permitir intercambio
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
		# limpiar hueco
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

# ----------------------------
# Modo INTERCAMBIO
# ----------------------------
func seleccionar_fichas_para_intercambio() -> Array:
	# Entrar en modo intercambio (aseguramos que NO estemos en reordenar)
	modo_reordenar = false
	modo_intercambio = true
	seleccionadas_para_intercambio.clear()
	print("✳️ Modo intercambio: selecciona las fichas que quieres cambiar. Pulsa ENTER o ESC para confirmar/salir.")

	await _esperar_salida_intercambio()

	# Salir
	modo_intercambio = false
	# restaurar colores
	for b in huecos:
		b.modulate = Color(1, 1, 1, 1)

	print("✅ Intercambio finalizado. Seleccionadas: %d" % seleccionadas_para_intercambio.size())
	return seleccionadas_para_intercambio.duplicate()

# ----------------------------
# Modo REORDENAR
# ----------------------------
func seleccionar_fichas_para_reordenar() -> void:
	# Entrar en modo reordenar (aseguramos que NO estemos en intercambio)
	modo_intercambio = false
	modo_reordenar = true
	ficha_reordenar_1 = null
	print("🔄 Modo reordenar: haz clic en la primera ficha y luego en la segunda para intercambiar. Pulsa ENTER o ESC para salir.")

	await _esperar_salida_reordenar()

	# Salir
	modo_reordenar = false
	ficha_reordenar_1 = null
	# restaurar colores
	for b in huecos:
		b.modulate = Color(1, 1, 1, 1)
	print("✅ Reordenamiento finalizado.")

func registrar_click_reordenar(boton: Button) -> void:
	if not modo_reordenar:
		return

	# Si el usuario pulsa una ficha vacía, ignorar
	if boton.icon == null:
		return

	if ficha_reordenar_1 == null:
		ficha_reordenar_1 = boton
		boton.modulate = Color(0.6, 1, 0.6, 1)  # verde claro
	else:
		# Intercambiar fichas en el GridContainer (ahora por contenido)
		_intercambiar_fichas_en_atril(ficha_reordenar_1, boton)
		# reset visual
		ficha_reordenar_1.modulate = Color(1, 1, 1, 1)
		boton.modulate = Color(1, 1, 1, 1)
		ficha_reordenar_1 = null

func registrar_click_intercambio(boton: Button) -> void:
	if not modo_intercambio:
		return

	# Ignorar huecos vacíos
	if boton.icon == null:
		return

	# Alternar selección
	if seleccionadas_para_intercambio.has(boton):
		seleccionadas_para_intercambio.erase(boton)
		boton.modulate = Color(1, 1, 1, 1)
	else:
		seleccionadas_para_intercambio.append(boton)
		boton.modulate = Color(0.6, 1, 0.6, 1)

# ----------------------------
# Intercambio por contenido (reemplaza mover nodos)
# ----------------------------
func _intercambiar_fichas_en_atril(b1: Button, b2: Button) -> void:
	if b1 == null or b2 == null or b1 == b2:
		return

	# Intercambiamos solo el contenido de las fichas para evitar problemas con la estructura de nodos
	var tmp_icon = b1.icon
	var tmp_text = b1.text
	var tmp_tooltip = b1.tooltip_text
	var tmp_meta_letra = null
	if b1.has_meta("letra"):
		tmp_meta_letra = b1.get_meta("letra")
	var tmp_disabled = b1.disabled
	var tmp_modulate = b1.modulate

	# Copiar contenido de b2 a b1
	b1.icon = b2.icon
	b1.text = b2.text
	b1.tooltip_text = b2.tooltip_text
	if b2.has_meta("letra"):
		b1.set_meta("letra", b2.get_meta("letra"))
	else:
		if b1.has_meta("letra"):
			b1.remove_meta("letra")
	b1.disabled = b2.disabled
	b1.modulate = b2.modulate

	# Restaurar contenido original en b2
	b2.icon = tmp_icon
	b2.text = tmp_text
	b2.tooltip_text = tmp_tooltip
	if tmp_meta_letra != null:
		b2.set_meta("letra", tmp_meta_letra)
	else:
		if b2.has_meta("letra"):
			b2.remove_meta("letra")
	b2.disabled = tmp_disabled
	b2.modulate = tmp_modulate

	# Reconstruir lista de huecos (por seguridad, aunque el orden de nodos no cambia)
	var grid: GridContainer = $VBoxContainer/Panel/GridContainer
	var nueva_lista: Array[Button] = []
	for c in grid.get_children():
		if c is Button and c.name.begins_with("Hueco"):
			nueva_lista.append(c)
	huecos = nueva_lista

	print("🔁 Fichas reordenadas (intercambio por contenido): %s <-> %s" % [b1.name, b2.name])

# ----------------------------
# Utilidades de espera (esperan ENTER o ESC para salir del modo)
# (Corregido para Godot 4.5: uso de await en lugar de yield)
# ----------------------------
func _esperar_salida_intercambio() -> void:
	# Espera hasta que el usuario presione ENTER o ESC
	while true:
		# espera un frame (evita busy loop)
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
			break

func _esperar_salida_reordenar() -> void:
	# Igual comportamiento que el de intercambio
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
			break
