extends Button

var manager: Node = null
var is_dragging: bool = false
var mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2.ZERO
const DRAG_THRESHOLD: float = 6.0

var drag_preview_manager: Node = null

func _ready() -> void:
	# Espera un frame para asegurarte de que la escena está completamente cargada
	await get_tree().process_frame
	# Buscar el nodo dentro de la escena actual (válido para Godot 4)
	drag_preview_manager = get_tree().get_current_scene().find_child("DragPreviewManager", true, false)

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
					if ok:
						if manager:
							manager.on_ficha_soltada(self)
					else:
						if manager:
							manager.on_ficha_soltada(self)
				else:
					if manager:
						manager.on_ficha_soltada(self)

				mouse_down = false
			else:
				# Click corto: seleccionar con teclado
				if mouse_down and self.icon:
					var board2 := get_tree().current_scene.get_node_or_null("Board")
					if board2 and board2.has_method("empezar_seleccion_desde_hueco"):
						board2.empezar_seleccion_desde_hueco(self.icon, self)
				mouse_down = false
				is_dragging = false

	elif event is InputEventMouseMotion:
		if mouse_down and not is_dragging:
			if (event.global_position - mouse_down_pos).length() > DRAG_THRESHOLD:
				is_dragging = true
				if drag_preview_manager:
					drag_preview_manager.start_preview(self.icon, self, event.global_position)
				if manager:
					manager.on_ficha_arrastrada(self)
		if is_dragging and drag_preview_manager:
			drag_preview_manager.update_preview(event.global_position)
