extends Button

var manager: Node = null

# Estado de arrastre
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_pos: Vector2 = Vector2.ZERO

# Estado de click/umbral
var mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2.ZERO
const DRAG_THRESHOLD: float = 6.0  # píxeles

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if self.icon == null:
				return
			mouse_down = true
			mouse_down_pos = event.global_position
			start_pos = global_position
		else:
			if is_dragging:
				is_dragging = false
				_reset_visuals()

				var board := get_tree().current_scene.get_node_or_null("Board")
				if board and board.has_method("soltar_ficha_en_tablero") and self.icon:
					var drop_pos: Vector2 = event.global_position
					var ok: bool = board.soltar_ficha_en_tablero(drop_pos, self.icon, self)
					if ok:
						if manager:
							manager.on_ficha_soltada(self)
						mouse_down = false
						return

				if manager:
					manager.on_ficha_soltada(self)
				var t := create_tween()
				t.tween_property(self, "global_position", start_pos, 0.25)\
				 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			else:
				# Clic corto: activar selección clic/teclado
				if mouse_down and self.icon:
					var board2 := get_tree().current_scene.get_node_or_null("Board")
					if board2 and board2.has_method("empezar_seleccion_desde_hueco"):
						board2.empezar_seleccion_desde_hueco(self.icon, self)

			mouse_down = false
			is_dragging = false

	elif event is InputEventMouseMotion:
		# Arranque de arrastre por umbral
		if mouse_down and not is_dragging:
			if (event.global_position - mouse_down_pos).length() >= DRAG_THRESHOLD:
				is_dragging = true
				drag_offset = get_local_mouse_position()
				_apply_drag_visuals()
				if manager:
					manager.on_ficha_arrastrada(self)

		if is_dragging:
			global_position = event.global_position - drag_offset

# Visuales durante arrastre
func _apply_drag_visuals() -> void:
	modulate = Color(1, 1, 1, 0.7)
	scale = Vector2(1.1, 1.1)
	z_index = 100

# Restaurar visuales
func _reset_visuals() -> void:
	modulate = Color(1, 1, 1, 1)
	scale = Vector2.ONE
	z_index = 0
