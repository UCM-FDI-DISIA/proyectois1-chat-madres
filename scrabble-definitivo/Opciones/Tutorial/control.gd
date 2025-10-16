extends Control

@export_dir var slides_folder := "res://Opciones/Tutorial/PNGs"  # carpeta con PNGs (01.png, 02.png, ...)

var slides: Array[String] = []
var i: int = 0

@onready var slide_tex: TextureRect = $Slide

func _ready() -> void:
	# Comprobación de nodos y estructura
	assert(slide_tex != null, "No existe un nodo 'Slide' como hijo del Control raíz. Árbol mal montado.")
	_load_slides()
	assert(slides.size() > 0, "No hay PNGs en: %s" % slides_folder)
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
	slides.sort() # nómbralos 01.png, 02.png... para orden

func _show(idx: int) -> void:
	if slides.is_empty(): return
	var tex := load(slides[idx]) as Texture2D
	if tex == null:
		push_error("No se pudo cargar: %s" % slides[idx]); return
	slide_tex.texture = tex
	# ayuda al Scroll/ajuste si luego expandes la escena
	slide_tex.custom_minimum_size = tex.get_size()
