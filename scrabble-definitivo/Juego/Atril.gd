extends PanelContainer

@export var cantidad_fichas_en_atril: int = 7
@onready var bolsa: Node = preload("res://scripts/BolsaFichas.gd").new()
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
var cancelar_reordenar_flag: bool = false

# ----------------------------
# READY / INICIALIZACIÓN
# ----------------------------
func _ready() -> void:
	# Inicializar bolsa si hace falta (si la clase bolsa lo requiere)
	if bolsa and bolsa.has_method("_inicializar_bolsa"):
		# comprobación defensiva: si la bolsa tiene lista interna 'bolsa' y está vacía, inicializarla
		if "bolsa" in bolsa and bolsa.bolsa is Array and bolsa.bolsa.is_empty():
			bolsa._inicializar_bolsa()

	# Recoger huecos y asignar manager
	var grid: GridContainer = $VBoxContainer/Panel/GridContainer
	for child in grid.get_children():
		if child is Button and child.name.begins_with("Hueco"):
			huecos.append(child)
			# asignar manager para que los huecos puedan notificar acciones
			child.manager = self

	_rellenar_atril()

# ----------------------------
# Relleno / Reposición
# ----------------------------
func _rellenar_atril() -> void:
	var nuevas_fichas: Array = []
	if bolsa and bolsa.has_method("sacar_fichas"):
		nuevas_fichas = bolsa.sacar_fichas(cantidad_fichas_en_atril)
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

	var nuevas_fichas: Array = []
	if bolsa and bolsa.has_method("sacar_fichas"):
		nuevas_fichas = bolsa.sacar_fichas(huecos_vacios.size())

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
# Drag preview helpers (huecos llaman a esto)
# ----------------------------
func on_ficha_arrastrada(boton: Button) -> void:
	if drag_preview_manager and boton and boton.icon:
		var mp := get_viewport().get_mouse_position()
		if drag_preview_manager.has_method("start_preview"):
			drag_preview_manager.start_preview(boton.icon, boton, mp)

func on_ficha_soltada(boton: Button) -> void:
	if drag_preview_manager and drag_preview_manager.has_method("stop_preview"):
		drag_preview_manager.stop_preview()

# ----------------------------
# Modo SELECCIÓN para INTERCAMBIO (devuelve Array o null si cancela)
# ----------------------------
# Nota: sin tipo de retorno explícito para permitir return null en caso de cancelación
func seleccionar_fichas_para_intercambio():
	# Activa modo intercambio y permite seleccionar fichas.
	# Devuelve:
	#  - Array con botones seleccionados si confirma con ENTER
	#  - null si cancela con ESC (ui_cancel)
	modo_reordenar = false
	modo_intercambio = true
	seleccionadas_para_intercambio = []

	# Evitar click "bleed-through" del botón que activa el modo
	await _wait_mouse_released()

	print("🔁 Modo intercambio: selecciona las fichas que quieras cambiar. Pulsa ENTER para confirmar, ESC para cancelar.")

	# Esperar confirmación (devuelve true si aceptó, false si canceló)
	var confirmado := await _esperar_salida_intercambio()

	# Si canceló, restaurar visual y devolver null
	if not confirmado:
		modo_intercambio = false
		seleccionadas_para_intercambio = []
		for b in huecos:
			b.modulate = Color(1, 1, 1, 1)
		return null

	# Si confirmó, copiamos la selección y salimos
	var result: Array = seleccionadas_para_intercambio.duplicate()
	modo_intercambio = false
	seleccionadas_para_intercambio = []
	for b in huecos:
		b.modulate = Color(1, 1, 1, 1)

	return result

func registrar_click_intercambio(boton: Button) -> void:
	if not modo_intercambio:
		return
	if boton == null or boton.icon == null:
		return
	if boton in seleccionadas_para_intercambio:
		seleccionadas_para_intercambio.erase(boton)
		boton.modulate = Color(1, 1, 1, 1)
	else:
		seleccionadas_para_intercambio.append(boton)
		boton.modulate = Color(1, 0.8, 0.4, 1)

func _esperar_salida_intercambio() -> bool:
	# Devuelve true si el usuario presionó ui_accept (ENTER), false si ui_cancel (ESC).
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			return true
		if Input.is_action_just_pressed("ui_cancel"):
			return false
	# Defensa adicional
	return false

# ----------------------------
# Ejecutar intercambio (separado: usado por pantalla_de_juego)
# ----------------------------
func intercambiar_fichas(botones: Array) -> void:
	if botones == null or botones.is_empty():
		print("⚠️ No hay fichas para intercambiar.")
		return
	if bolsa and bolsa.has_method("quedan") and bolsa.quedan() < 7:
		print("⚠️ No puedes intercambiar: quedan menos de 7 fichas en la bolsa.")
		return

	var fichas_devueltas: Array = []
	for b in botones:
		if b == null:
			continue
		if b.icon == null or not b.has_meta("letra"):
			continue
		var letra: String = str(b.get_meta("letra"))
		var tex: Texture2D = b.icon
		var puntos: int = 0
		for f in fichas_en_atril:
			if f is Dictionary and f.has("letra") and f["letra"] == letra:
				puntos = int(f.get("puntos", 0))
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

	if bolsa and bolsa.has_method("devolver_fichas"):
		bolsa.devolver_fichas(fichas_devueltas)

	var nuevas: Array = []
	if bolsa and bolsa.has_method("sacar_fichas"):
		nuevas = bolsa.sacar_fichas(botones.size())

	for i in range(botones.size()):
		var b2: Button = botones[i]
		if b2 == null:
			continue
		if i >= nuevas.size():
			continue
		var f: Dictionary = nuevas[i] as Dictionary
		b2.icon = f.get("texture")
		b2.text = ""
		b2.tooltip_text = "Letra: %s\nPuntos: %d" % [f.get("letra"), int(f.get("puntos", 0))]
		if f.has("letra"):
			b2.set_meta("letra", f.get("letra"))

	print("✅ Intercambio completado: %d fichas nuevas." % botones.size())

# ----------------------------
# Modo REORDENAR (intercambia posiciones dentro del atril)
# ----------------------------
func seleccionar_fichas_para_reordenar() -> void:
	modo_intercambio = false
	modo_reordenar = true
	ficha_reordenar_1 = null
	cancelar_reordenar_flag = false

	# Evitar bleed-through del click del botón que activa este modo
	await _wait_mouse_released()

	print("🔄 Modo reordenar: haz clic en la primera ficha y luego en la segunda para intercambiar. Pulsa ENTER o ESC para salir (o pulsa otra vez el botón Reordenar para cancelar).")

	await _esperar_salida_reordenar()

	modo_reordenar = false
	ficha_reordenar_1 = null
	for b in huecos:
		b.modulate = Color(1, 1, 1, 1)
	if cancelar_reordenar_flag:
		print("⚠️ Reordenamiento cancelado por el usuario.")
	else:
		print("✅ Reordenamiento finalizado.")

func registrar_click_reordenar(boton: Button) -> void:
	if not modo_reordenar:
		return
	if boton == null or boton.icon == null:
		return

	if ficha_reordenar_1 == null:
		ficha_reordenar_1 = boton
		boton.modulate = Color(0.6, 1, 0.6, 1)
	else:
		_intercambiar_fichas_en_atril(ficha_reordenar_1, boton)
		ficha_reordenar_1.modulate = Color(1, 1, 1, 1)
		boton.modulate = Color(1, 1, 1, 1)
		ficha_reordenar_1 = null

# Intercambia visual y datos entre dos huecos (botones)
func _intercambiar_fichas_en_atril(a: Button, b: Button) -> void:
	if a == null or b == null:
		return
	var icon_a = a.icon
	var text_a = a.text
	var tooltip_a = a.tooltip_text
	var meta_letra_a = null
	if a.has_meta("letra"):
		meta_letra_a = a.get_meta("letra")
	var disabled_a = a.disabled

	var icon_b = b.icon
	var text_b = b.text
	var tooltip_b = b.tooltip_text
	var meta_letra_b = null
	if b.has_meta("letra"):
		meta_letra_b = b.get_meta("letra")
	var disabled_b = b.disabled

	a.icon = icon_b
	a.text = text_b
	a.tooltip_text = tooltip_b
	if meta_letra_b != null:
		a.set_meta("letra", meta_letra_b)
	else:
		if a.has_meta("letra"):
			a.remove_meta("letra")
	a.disabled = disabled_b

	b.icon = icon_a
	b.text = text_a
	b.tooltip_text = tooltip_a
	if meta_letra_a != null:
		b.set_meta("letra", meta_letra_a)
	else:
		if b.has_meta("letra"):
			b.remove_meta("letra")
	b.disabled = disabled_a

	var i_a = huecos.find(a)
	var i_b = huecos.find(b)
	if i_a >= 0 and i_b >= 0 and i_a < fichas_en_atril.size() and i_b < fichas_en_atril.size():
		var temp = fichas_en_atril[i_a]
		fichas_en_atril[i_a] = fichas_en_atril[i_b]
		fichas_en_atril[i_b] = temp

func cancelar_reordenar() -> void:
	if not modo_reordenar:
		return
	cancelar_reordenar_flag = true

func _esperar_salida_reordenar() -> void:
	while true:
		await get_tree().process_frame
		if cancelar_reordenar_flag:
			break
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
			break

func _wait_mouse_released() -> void:
	while Input.is_mouse_button_pressed(1):
		await get_tree().process_frame
