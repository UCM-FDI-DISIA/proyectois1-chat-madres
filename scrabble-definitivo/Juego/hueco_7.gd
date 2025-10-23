extends Button

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 🔹 Coger ficha
			is_dragging = true
			drag_offset = get_local_mouse_position()
			modulate = Color(1, 1, 1, 0.7)
			scale = Vector2(1.15, 1.15)
			z_index = 100
		else:
			# 🔹 Soltar ficha
			is_dragging = false
			modulate = Color(1, 1, 1, 1)
			scale = Vector2.ONE
			z_index = 0
	elif event is InputEventMouseMotion and is_dragging:
		# 🔹 Mover mientras se arrastra
		position += event.relative
