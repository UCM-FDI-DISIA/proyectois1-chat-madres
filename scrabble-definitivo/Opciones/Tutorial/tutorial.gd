extends Control

@export var fade_time: float = 0.5
@export var sprite_paths: Array[String] = [] # Rutas a las imágenes originales

var _sprites_originales: Array[Sprite2D] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP  # Bloquea clics al menú mientras esté el tutorial
	
	# Guardamos copias de las capas iniciales (para restablecerlas luego)
	for n in get_children():
		if n is Sprite2D:
			_sprites_originales.append(n.duplicate())
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_eliminar_capa_superior()

func _eliminar_capa_superior() -> void:
	var visibles := _contar_sprites_visibles()
	
	if visibles <= 0:
		# 🔹 Si no quedan capas visibles, las restablecemos
		_reestablecer_capas()
		return
		
	elif visibles == 1:
		# 🔹 Si solo queda una imagen, la eliminamos y luego restablecemos
		var sprite := _get_sprite_superior()
		if sprite:
			var t := create_tween()
			t.tween_property(sprite, "modulate:a", 0.0, fade_time * 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			t.tween_callback(func():
				if is_instance_valid(sprite):
					sprite.queue_free()
				_reestablecer_capas()
			)
		return

	# 🔹 Caso normal: hay más de una capa visible
	var sprite := _get_sprite_superior()
	if sprite == null:
		return

	var t := create_tween()
	t.tween_property(sprite, "modulate:a", 0.0, fade_time * 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(func():
		if is_instance_valid(sprite):
			sprite.queue_free()
	)

func _get_sprite_superior() -> Sprite2D:
	var hijos := get_children()
	for i in range(hijos.size() - 1, -1, -1):
		var n := hijos[i]
		if n is Sprite2D and (n as Sprite2D).visible:
			return n as Sprite2D
	return null

func _contar_sprites_visibles() -> int:
	var c := 0
	for n in get_children():
		if n is Sprite2D and (n as Sprite2D).visible:
			c += 1
	return c

func _reestablecer_capas() -> void:
	# 🔹 Borra todo y vuelve a agregar las copias originales
	for n in get_children():
		if n is Sprite2D:
			n.queue_free()
	
	for s in _sprites_originales:
		var nuevo := s.duplicate()
		add_child(nuevo)
		nuevo.modulate.a = 1.0

func _on_salir_pressed() -> void:
	queue_free()
