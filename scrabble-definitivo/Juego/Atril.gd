extends PanelContainer

@export_dir var icons_folder := "res://Casillas/Fichas"

var icon_textures: Array[Texture2D] = []
var huecos: Array[Button] = []

func _ready():
	_load_icons()
	var grid := $VBoxContainer/Panel/GridContainer
	for child in grid.get_children():
		if child is Button and child.name.begins_with("Hueco"):
			huecos.append(child)
	_set_random_icons()

func _load_icons():
	icon_textures.clear()
	var dir := DirAccess.open(icons_folder)
	if dir == null:
		push_error("No se pudo abrir: %s" % icons_folder); return
	dir.list_dir_begin()
	while true:
		var f := dir.get_next()
		if f == "": break
		if dir.current_is_dir(): continue
		if f.to_lower().ends_with(".png"):
			var tex := load(icons_folder.path_join(f)) as Texture2D
			if tex: icon_textures.append(tex)
	dir.list_dir_end()
	if icon_textures.is_empty():
		push_warning("No hay PNGs en %s" % icons_folder)

func _set_random_icons():
	if icon_textures.is_empty(): return
	var rng := RandomNumberGenerator.new()
	for b in huecos:
		var tex := icon_textures[rng.randi_range(0, icon_textures.size() - 1)]
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.custom_minimum_size = Vector2(40, 40)
		b.icon = tex
