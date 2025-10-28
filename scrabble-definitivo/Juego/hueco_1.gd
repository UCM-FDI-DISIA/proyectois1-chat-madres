extends Button

var manager: Node = null
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var start_pos: Vector2 = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = get_local_mouse_position()
			start_pos = global_position
			modulate = Color(1, 1, 1, 0.7)
			scale = Vector2(1.1, 1.1)
			z_index = 100
			if manager:
				manager.on_ficha_arrastrada(self)
		else:
			if is_dragging:
				is_dragging = false
				modulate = Color(1, 1, 1, 1)
				scale = Vector2.ONE
				z_index = 0

				# intentar colocar en tablero usando la posición global del soltar
				var board := get_tree().current_scene.get_node_or_null("Board")
				if board and board.has_method("soltar_ficha_en_tablero") and self.icon:
					var drop_pos: Vector2 = event.global_position
					var ok: bool = board.soltar_ficha_en_tablero(drop_pos, self.icon, self)
					if ok:
						if manager:
							manager.on_ficha_soltada(self)
						return

				# si no se colocó, vuelve al hueco
				if manager:
					manager.on_ficha_soltada(self)
				var t := create_tween()
				t.tween_property(self, "global_posif6tion", start_pos, 0.25)\
					.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	elif event is InputEventMouseMotion and is_dragging:
		global_position = event.global_position - drag_offset
