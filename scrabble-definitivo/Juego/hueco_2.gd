extends Button

var manager: Node = null
var is_dragging := false
var drag_offset := Vector2.ZERO
var start_pos := Vector2.ZERO

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

				if manager:
					manager.on_ficha_soltada(self)

				# Animar vuelta de la ficha a su posición original
				var t := create_tween()
				t.tween_property(self, "global_position", start_pos, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	elif event is InputEventMouseMotion and is_dragging:
		global_position = event.global_position - drag_offset
