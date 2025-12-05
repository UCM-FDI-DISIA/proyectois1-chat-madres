extends Control

func _seleccionar_jugadores(num):
	print("Número de jugadores seleccionados:", num)
	
	# Guardar número de jugadores
	GameData.num_jugadores = num
	
	# Inicializar puntuaciones
	GameData.puntuaciones = []
	for i in range(num):
		GameData.puntuaciones.append(0)

	# Empezar por el jugador 0
	GameData.jugador_actual = 0

	get_tree().change_scene_to_file("res://Opciones/Menú principal/PlayerMenu.tscn")


func _on_boton_1_pressed() -> void:
	_seleccionar_jugadores(1)

func _on_boton_2_pressed() -> void:
	_seleccionar_jugadores(2)

func _on_boton_3_pressed() -> void:
	_seleccionar_jugadores(3)

func _on_boton_4_pressed() -> void:
	_seleccionar_jugadores(4)
