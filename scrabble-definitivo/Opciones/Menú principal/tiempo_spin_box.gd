extends Control

func _ready():
	# Inicializar SpinBox con valor de GameData si existe
	if $TiempoSpinBox:
		$TiempoSpinBox.value = GameData.tiempo_por_turno if "tiempo_por_turno" in GameData else 30
	
	# Conectar botón
	if $ConfirmarBtn:
		$ConfirmarBtn.pressed.connect(_on_confirmar_pressed)

func _on_confirmar_pressed():
	# Guardar tiempo por turno
	if $TiempoSpinBox:
		GameData.tiempo_por_turno = $TiempoSpinBox.value
		print("⏱ Tiempo por turno configurado:", GameData.tiempo_por_turno, "segundos")
	
	# Ir a la selección de jugadores
	get_tree().change_scene_to_file("res://Juego/PantallaSeleccionJugadores.tscn")
