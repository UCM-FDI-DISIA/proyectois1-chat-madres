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
	add_child(preview_sprite)

func start_preview(icon: Texture, source: Button, position: Vector2) -> void:
	if not icon:
		return
	active = true
	source_hueco = source
	preview_sprite.texture = icon
	preview_sprite.visible = true
	preview_sprite.global_position = position - preview_sprite.size / 2
	preview_sprite.modulate = Color(1, 1, 1, 0.8)
	preview_sprite.scale = Vector2.ONE * 1.2

func update_preview(position: Vector2) -> void:
	if active:
		preview_sprite.global_position = position - preview_sprite.size / 2

func stop_preview() -> void:
	active = false
	preview_sprite.visible = false
	preview_sprite.texture = null
	source_hueco = null
