extends Control

var es_mi_turno: bool = false

const OPTIONS_SCENE := preload("res://Opciones/opciones.tscn")

func _ready() -> void:
	set_turno(true)
	_crear_boton_fin_turno()


# ===========================
# 🔹 Control de turno
# ===========================

func set_turno(mi_turno: bool) -> void:
	es_mi_turno = mi_turno
	if es_mi_turno:
		$ColorRect.mostrar_con_fundido()


func _on_opciones_pressed() -> void:
	var t = OPTIONS_SCENE.instantiate()
	get_tree().current_scene.add_child(t)


# ===========================
# 🔹 BOTÓN "FINALIZAR TURNO"
# ===========================

func _crear_boton_fin_turno() -> void:
	var boton := Button.new()
	boton.text = "Finalizar turno"
	boton.name = "BotonFinTurno"
	boton.custom_minimum_size = Vector2(200, 50)

	# Anchors al centro horizontal y abajo
	boton.anchor_left = 0.5
	boton.anchor_right = 0.5
	boton.anchor_top = 1.0
	boton.anchor_bottom = 1.0

	# Posición relativa al punto central inferior
	boton.position = Vector2(-100, -70)

	boton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	boton.connect("pressed", Callable(self, "_on_finalizar_turno_pressed"))
	add_child(boton)


func _on_finalizar_turno_pressed() -> void:
	if not es_mi_turno:
		return

	var tablero := get_tree().current_scene.get_node_or_null("Board")
	if tablero == null:
		push_warning("No se encontró el nodo 'Board'")
		return

	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		push_warning("No se encontró el nodo 'PanelContainer' (atril)")
		return

	# Bloquear la colocación
	es_mi_turno = false

	# Bloquear botones del atril
	if atril:
		for child in atril.get_children():
			if child is Button:
				child.disabled = true

	# Atenuar el tablero
	if tablero:
		tablero.modulate = Color(1, 1, 1, 0.6)

	# Validar jugada (simulado)
	_validar_jugada(tablero)

	# Limpiar fichas del turno
	tablero.limpiar_fichas_turno()


# ===========================
# 🔹 VALIDACIÓN DE JUGADA
# ===========================

func _validar_jugada(tablero: Node) -> void:
	if tablero == null:
		_reactivar_turno()
		return

	var dict = tablero.get("celdas_ocupadas")
	if typeof(dict) != TYPE_DICTIONARY:
		_reactivar_turno()
		return

	var fichas_colocadas: Array = dict.keys()
	if fichas_colocadas.is_empty():
		_reactivar_turno()
		return

	print("🔍 Jugada del turno validada (simulado).")
	await get_tree().create_timer(1.0).timeout
	_reactivar_turno()


# ===========================
# 🔹 REACTIVAR TURNO
# ===========================

func _reactivar_turno() -> void:
	var tablero := get_tree().current_scene.get_node_or_null("Board")
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")

	if atril:
		for child in atril.get_children():
			if child is Button:
				child.disabled = false

	if tablero:
		tablero.modulate = Color(1, 1, 1, 1)

	es_mi_turno = true
	print("🔁 Turno reactivado.")
