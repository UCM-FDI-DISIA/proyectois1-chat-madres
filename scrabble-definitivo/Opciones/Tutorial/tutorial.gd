extends Control

@export var fade_time: float = 0.3  # segundos del fundido

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP  # captura clics sobre el Control

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_eliminar_capa_superior()

func _eliminar_capa_superior() -> void:
	var hijos: Array = get_children()
	if hijos.is_empty():
		return

	var sprite: Sprite2D = null
	for i in range(hijos.size() - 1, -1, -1):
		var n: Node = hijos[i]
		if n is Sprite2D and (n as Sprite2D).visible:
			sprite = n as Sprite2D
			break

	if sprite == null:
		return

	var t: Tween = create_tween()
	t.tween_property(sprite, "modulate:a", 0.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(func():
		sprite.queue_free()
		# opcional: si ya no quedan sprites visibles, ocultar el contenedor
		if not _hay_sprites_visibles():
			hide()
	)

func _hay_sprites_visibles() -> bool:
	for n in get_children():
		if n is Sprite2D and (n as Sprite2D).visible:
			return true
	return false
