extends Button

var manager: Node = null
var is_dragging: bool = false
var mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2.ZERO
const DRAG_THRESHOLD: float = 6.0

@onready var drag_preview_manager: Node = get_tree().get_current_scene().find_child("DragPreviewManager", true, false)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if self.icon == null:
				return
			mouse_down = true
			mouse_down_pos = event.global_position
		else:
			# Botón soltado
			if is_dragging:
				is_dragging = false
				if drag_preview_manager:
					drag_preview_manager.stop_preview()

				var board := get_tree().current_scene.get_node_or_null("Board")
				if board and board.has_method("soltar_ficha_en_tablero"):
					var ok: bool = board.soltar_ficha_en_tablero(event.global_position, self.icon, self)
					if manager:
						manager.on_ficha_soltada(self)
			else:
				# 🔹 Click corto: seleccionar ficha o marcar para intercambio
				if mouse_down and self.icon:
					var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
					if atril and atril.has_method("registrar_click_intercambio") and atril.modo_intercambio:
						# MODO INTERCAMBIO → marcar/deseleccionar ficha
						atril.registrar_click_intercambio(self)
					else:
						# MODO NORMAL → seleccionar para colocar en tablero
						var board2 := get_tree().current_scene.get_node_or_null("Board")
						if board2 and board2.has_method("empezar_seleccion_desde_hueco"):
							board2.empezar_seleccion_desde_hueco(self.icon, self)
					mouse_down = false
					is_dragging = false
			mouse_down = false

	elif event is InputEventMouseMotion:
		if mouse_down and not is_dragging:
			if (event.global_position - mouse_down_pos).length() > DRAG_THRESHOLD:
				is_dragging = true
				if manager:
					manager.on_ficha_arrastrada(self)
		if is_dragging and drag_preview_manager:
			drag_preview_manager.update_preview(event.global_position)
