extends Control

@onready var tiempo_spinbox: SpinBox = $VBoxContainer/botones/TiempoSpinBox
@onready var boton: Button = $VBoxContainer/botones/Button
@onready var fondo: TextureRect = $FondoEspecial
@onready var color_fondo: ColorRect = $FondoNegro

func _ready() -> void:
	_actualizar_fondo()
	# Inicializar SpinBox con el valor actual de GameData
	if tiempo_spinbox:
		tiempo_spinbox.value = GameData.tiempo_por_turno

	# Conectar el botón a la función _on_Button_pressed
	if boton and not boton.pressed.is_connected(_on_Button_pressed):
		boton.pressed.connect(_on_Button_pressed)
		print("DEBUG: botón 'Button' conectado a _on_Button_pressed")
	else:
		print("DEBUG: NO se ha podido conectar el botón (¿no existe?)")
	
	

func _on_Button_pressed() -> void:
	print("DEBUG: _on_Button_pressed llamado")

	# Guardar tiempo por turno
	if tiempo_spinbox:
		GameData.tiempo_por_turno = tiempo_spinbox.value
		print("⏱ Tiempo por turno configurado:", GameData.tiempo_por_turno, "segundos")
	else:
		print("DEBUG: NO se encontró TiempoSpinBox")

	# Cambiar a la pantalla de juego
	var err := get_tree().change_scene_to_file("res://Opciones/Menú principal/Pantalla de carga.tscn")
	print("DEBUG: change_scene_to_file ->", err)


# ===================================
# 🔹 Cambiar fondo según temática
# ===================================
func _actualizar_fondo() -> void:
	var tema = GameData.selected_theme
	var ruta : String = ""

	match tema:
		"navidad":
			ruta = "res://Opciones/FONDOS TEMATICAS/NAVIDADFONDOMULTIJUGADOR.jpg"
		"naturaleza":
			ruta = "res://Opciones/FONDOS TEMATICAS/NATURALEZAMULTI.jpg"
			var textLabel = $VBoxContainer/Label
			var textTiempo = $VBoxContainer/botones/Tiempo
			var textButton = $VBoxContainer/botones/Button
			textLabel.add_theme_color_override("font_color", Color(0,0,0))
			textTiempo.add_theme_color_override("font_color", Color(0,0,0))
			textButton.add_theme_color_override("font_color", Color(0,0,0))
		"ciencia":
			ruta = "res://Opciones/FONDOS TEMATICAS/CIENCIAMULTI.jpg"
		"arte":
			ruta = "res://Opciones/FONDOS TEMATICAS/ARTEMULTI.jpg"
		_:
			if fondo:
				fondo.texture = null
				fondo.visible = false
			if color_fondo:
				color_fondo.visible = true
			return

	#CARGAR TEXTURA
	var tex: Texture2D = load(ruta)
	if tex != null:
		fondo.texture = tex
		fondo.visible = true
		if color_fondo:
			color_fondo.visible = false
		
