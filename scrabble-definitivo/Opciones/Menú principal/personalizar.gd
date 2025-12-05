extends Control

@onready var tiempo_spinbox: SpinBox = $TiempoSpinBox
@onready var boton: Button = $Button


func _ready() -> void:
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
	var err := get_tree().change_scene_to_file("res://Juego/Pantalla de Juego.tscn")
	print("DEBUG: change_scene_to_file ->", err)
