extends Control

#func _ready():
	# Conecta cada botón usando lambdas (compatible Godot 4)
	#$boton1.connect("pressed", func(): _seleccionar_jugadores(1))
	#$boton2.connect("pressed", func(): _seleccionar_jugadores(2))
	#$boton3.connect("pressed", func(): _seleccionar_jugadores(3))
	#$boton4.connect("pressed", func(): _seleccionar_jugadores(4))

func _seleccionar_jugadores(num):
	print("Número de jugadores seleccionados:", num)
	
	#aqui se guarda la variable en el autoload GameData
	GameData.num_jugadores = num
	
	#inicializar array de puntuaciones
	GameData.puntuaciones = []
	
	for i in range(num):
		GameData.puntuaciones.append(0)
	
	#empezar por el jugador 0
	GameData.jugador_actual = 0
	
	# Si elige 1 jugador carga el juego normal
	if num == 1:
		get_tree().change_scene_to_file("res://Juego/Pantalla de juego.tscn")
		return

	# Para 2–4 jugadores (misma escena...)
	get_tree().change_scene_to_file("res://Juego/Pantalla de juego.tscn")

func _on_boton_1_pressed() -> void:
	_seleccionar_jugadores(1)


func _on_boton_2_pressed() -> void:
	_seleccionar_jugadores(2)


func _on_boton_3_pressed() -> void:
	_seleccionar_jugadores(3)


func _on_boton_4_pressed() -> void:
	_seleccionar_jugadores(4)
