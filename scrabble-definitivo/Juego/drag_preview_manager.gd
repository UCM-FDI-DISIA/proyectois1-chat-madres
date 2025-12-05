extends Node2D

# Este nodo se encarga de mostrar una "ficha fantasma" durante el arrastre.

var preview_sprite: TextureRect
var active: bool = false
var source_hueco: Button = null

func _ready() -> void:
	# Creamos el TextureRect que actuará como ficha "fantasma"
	preview_sprite = TextureRect.new()
	preview_sprite.visible = false
	preview_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_sprite.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_sprite.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	preview_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(preview_sprite)

func start_preview(icon: Texture2D, source: Node, preview_position: Vector2) -> void:
	if icon == null:
		return
	active = true
	source_hueco = source
	preview_sprite.texture = icon

	# 🔧 Tamaño objetivo
	var target_size = Vector2(64, 64)
	var final_size = target_size

	if icon.get_size() != Vector2.ZERO:
		var tex_size = icon.get_size()
		var scale_factor = min(target_size.x / tex_size.x, target_size.y / tex_size.y)
		final_size = tex_size * scale_factor
		preview_sprite.scale = Vector2.ONE * scale_factor
	else:
		preview_sprite.scale = Vector2.ONE

	preview_sprite.visible = true
	preview_sprite.global_position = preview_position - final_size * 0.5
	preview_sprite.modulate = Color(1, 1, 1, 0.9)

func update_preview(preview_position: Vector2) -> void:
	if active:
		var tex_size = preview_sprite.texture.get_size()
		var scaled_size = tex_size * preview_sprite.scale
		preview_sprite.global_position = preview_position - scaled_size * 0.5

func stop_preview() -> void:
	active = false
	preview_sprite.visible = false
	preview_sprite.texture = null
	source_hueco = null
