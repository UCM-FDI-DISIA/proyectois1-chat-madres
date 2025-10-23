extends Control

@export var fade_time: float = 0.5

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP  # bloquea clics al menú mientras esté el tutorial

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_eliminar_capa_superior()

func _eliminar_capa_superior() -> void:
	var visibles := _contar_sprites_visibles()
	if visibles <= 0:
		_cerrar_tutorial()
		return
	elif visibles == 1:
		# 🔹 si solo queda una imagen, la eliminamos y cerramos automáticamente
		var sprite := _get_sprite_superior()
		if sprite:
			var t := create_tween()
			t.tween_property(sprite, "modulate:a", 0.0, fade_time * 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			t.tween_callback(func():
				if is_instance_valid(sprite):
					sprite.queue_free()
				_cerrar_tutorial()
			)
		return

	# 🔹 caso normal: hay más de una capa
	var sprite := _get_sprite_superior()
	if sprite == null:
		_cerrar_tutorial()
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

func _cerrar_tutorial() -> void:
	# 🔹 fundido a negro y cambio al menú
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.size = get_viewport_rect().size
	add_child(fade)

	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(func():
		get_tree().change_scene_to_file("res://Opciones/opciones.tscn")  # ⚠️ pon tu ruta exacta aquí
	)
