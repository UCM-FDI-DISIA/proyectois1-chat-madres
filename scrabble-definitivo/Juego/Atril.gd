extends PanelContainer

@export_dir var icons_folder := "res://Casillas/Fichas"

var icon_textures: Array[Texture2D] = []
var huecos: Array[Button] = []

func _ready() -> void:
	_load_icons()
	var grid := $VBoxContainer/Panel/GridContainer
	for child in grid.get_children():
		if child is Button and child.name.begins_with("Hueco"):
			huecos.append(child)
	_set_random_icons()

func _load_icons() -> void:
	icon_textures.clear()
	var dir := DirAccess.open(icons_folder)
	if dir == null:
		push_error("No se pudo abrir: %s" % icons_folder)
		return
	dir.list_dir_begin()
	while true:
		var f := dir.get_next()
		if f == "": break
		if dir.current_is_dir(): continue
		if f.to_lower().ends_with(".png"):
			var tex := load(icons_folder.path_join(f)) as Texture2D
			if tex: icon_textures.append(tex)
	dir.list_dir_end()

func _set_random_icons() -> void:
	if icon_textures.is_empty():
		return
	var shuffled_icons: Array[Texture2D] = icon_textures.duplicate()
	shuffled_icons.shuffle()
	var n: int = min(huecos.size(), shuffled_icons.size())

	for i in range(huecos.size()):
		var b: Button = huecos[i]
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = Vector2(40, 40)
		b.icon = shuffled_icons[i] if i < n else null


# === NUEVA LÓGICA DE ANIMACIÓN ===

# 🔹 Cuando se empieza a arrastrar una ficha
func on_ficha_arrastrada(ficha: Button) -> void:
	for b in huecos:
		if b != ficha:
			var t := create_tween()
			t.tween_property(b, "position:x", 60, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# 🔹 Cuando se suelta la ficha
func on_ficha_soltada(ficha: Button) -> void:
	for b in huecos:
		if b != ficha:
			var t := create_tween()
			t.tween_property(b, "position:x", 0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
