extends Button

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Al hacer clic, marcamos inicio del drag
				is_dragging = true
				drag_offset = get_local_mouse_position()
				modulate = Color(1, 1, 1, 0.7) # semitransparente
				scale = Vector2(1.15, 1.15)   # agrandar un poco
				z_index = 100                 # traer al frente
			else:
				# Al soltar el clic, soltar ficha
				is_dragging = false
				modulate = Color(1, 1, 1, 1)  # opacidad normal
				scale = Vector2(1, 1)         # tamaño normal
				z_index = 0                   # devolver al fondo

	elif event is InputEventMouseMotion and is_dragging:
		# Mientras mueves el ratón con el botón pulsado
		position += event.relative  # mover la ficha
