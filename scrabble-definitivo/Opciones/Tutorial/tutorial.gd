extends Control

@export_dir var slides_folder := "res://Opciones/Tutorial/PNGs"  # carpeta con tus PNGs (01.png, 02.png, ...)

var slides: Array[String] = []
var i: int = 0

var slide_tex: TextureRect

func _ready() -> void:
	# Asegura que existe un TextureRect llamado "Slide"
	slide_tex = get_node_or_null("Slide") as TextureRect
	if slide_tex == null:
		# intentar hallarlo en profundidad por si está en otro sitio
		slide_tex = find_child("Slide", true, false) as TextureRect
	if slide_tex == null:
		# CREARLO si no existe
		slide_tex = TextureRect.new()
		slide_tex.name = "Slide"
		# que ocupe toda la pantalla y mantenga proporción
		slide_tex.set_anchors_preset(Control.PRESET_FULL_RECT) # Full Rect
		slide_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# si tienes un ScrollContainer llamado "Scroll", cuélgalo ahí; si no, del root
		var scroll := find_child("Scroll", true, false) as ScrollContainer
		if scroll:
			scroll.add_child(slide_tex)
		else:
			add_child(slide_tex)

	# Cargar y mostrar
	_load_slides()
	if slides.is_empty():
		push_error("No hay PNGs en: %s" % slides_folder)
		return
	_show(i)
	set_process_input(true)

func _input(e: InputEvent) -> void:
	if e is InputEventKey and e.is_pressed():
		match e.keycode:
			KEY_ESCAPE: queue_free()
			KEY_LEFT, KEY_A:
				i = (i - 1 + slides.size()) % slides.size()
				_show(i)
			KEY_RIGHT, KEY_D, KEY_SPACE, KEY_ENTER:
				i = (i + 1) % slides.size()
				_show(i)

func _load_slides() -> void:
	slides.clear()
	var d := DirAccess.open(slides_folder)
	if d == null:
		push_error("No se pudo abrir la carpeta: %s" % slides_folder)
		return
	d.list_dir_begin()
	while true:
		var f := d.get_next()
		if f == "": break
		if d.current_is_dir(): continue
		if f.to_lower().ends_with(".png"):
			slides.append(slides_folder.path_join(f))
	d.list_dir_end()
	slides.sort()  # nómbralos 01.png, 02.png... para mantener el orden

func _show(idx: int) -> void:
	if slides.is_empty(): return
	var tex := load(slides[idx]) as Texture2D
	if tex == null:
		push_error("No se pudo cargar: %s" % slides[idx]); return
	slide_tex.texture = tex
	slide_tex.custom_minimum_size = tex.get_size()
