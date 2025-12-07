extends Control

@onready var row1 = $VBoxContainer/HBoxContainer
@onready var row2 = $VBoxContainer/HBoxContainer2
@onready var row3 = $VBoxContainer/HBoxContainer3
@onready var row4 = $VBoxContainer/HBoxContainer4

@onready var p1 = $VBoxContainer/HBoxContainer/player1_input
@onready var p2 = $VBoxContainer/HBoxContainer2/player2_input
@onready var p3 = $VBoxContainer/HBoxContainer3/player3_input
@onready var p4 = $VBoxContainer/HBoxContainer4/player4_input

@onready var fondo = $TextureRect        # TextureRect de fondo
@onready var color_fondo = $ColorRect   # ColorRect de fondo (negro si no hay imagen)
@onready var titulo = $Label  # Label del título
@onready var text_player_1 = $"VBoxContainer/HBoxContainer/Jugador 1"
@onready var text_player_2 = $"VBoxContainer/HBoxContainer2/Jugador 2"
@onready var text_player_3 = $"VBoxContainer/HBoxContainer3/Jugador 3"
@onready var text_player_4 = $"VBoxContainer/HBoxContainer4/Jugador 4"

func _ready():
	
	_actualizar_fondo() 
	
	# Mostrar/ocultar según GameData.num_jugadores
	var n = GameData.num_jugadores
	
	row1.visible = n >= 1
	row2.visible = n >= 2
	row3.visible = n >= 3
	row4.visible = n >= 4
	
	# Asegurarnos de que GameData.player_names tiene al menos n posiciones
	if GameData.player_names == null:
		GameData.player_names = []

	while GameData.player_names.size() < n:
		GameData.player_names.append("")  # rellenamos con vacío
	
	# Cargar los nombres guardados
	if n >= 1: p1.text = GameData.player_names[0]
	if n >= 2: p2.text = GameData.player_names[1]
	if n >= 3: p3.text = GameData.player_names[2]
	if n >= 4: p4.text = GameData.player_names[3]



func _actualizar_fondo():
	match GameData.selected_theme:
		"navidad":
			fondo.texture = load("res://Opciones/FONDOS TEMATICAS/NAVIDADFONDOMULTIJUGADOR.jpg")
			fondo.visible = true
			color_fondo.visible = false
			titulo.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_1.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_2.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_3.add_theme_color_override("font_color", Color(1,1,1))  # blancoau
			text_player_4.add_theme_color_override("font_color", Color(1,1,1))  # blanco
		"naturaleza":
			fondo.texture = load("res://Opciones/FONDOS TEMATICAS/NATURALEZAMULTI.jpg")
			fondo.visible = true
			color_fondo.visible = false
			titulo.add_theme_color_override("font_color", Color(0,0,0))  # negro
			text_player_1.add_theme_color_override("font_color", Color(0,0,0))
			text_player_2.add_theme_color_override("font_color", Color(0,0,0))
			text_player_3.add_theme_color_override("font_color", Color(0,0,0))
			text_player_4.add_theme_color_override("font_color", Color(0,0,0))
		"ciencia":
			fondo.texture = load("res://Opciones/FONDOS TEMATICAS/CIENCIAMULTI.jpg")
			fondo.visible = true
			color_fondo.visible = false
			titulo.add_theme_color_override("font_color", Color(1,1,1))
			text_player_1.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_2.add_theme_color_override("font_color", Color(1,1,1))  # blancoautowrap_mode
			text_player_3.add_theme_color_override("font_color", Color(1,1,1))  # blancoautowrap_mode
			text_player_4.add_theme_color_override("font_color", Color(1,1,1))  # blanco
		"arte":
			fondo.texture = load("res://Opciones/FONDOS TEMATICAS/ARTEMULTI.jpg")
			fondo.visible = true
			color_fondo.visible = false
			titulo.add_theme_color_override("font_color", Color(1,1,1))
			text_player_1.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_2.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_3.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_4.add_theme_color_override("font_color", Color(1,1,1))  # blanco
		_:
			# No hay temática → fondo negro
			fondo.texture = null
			fondo.visible = false
			color_fondo.visible = true
			titulo.add_theme_color_override("font_color", Color(1,1,1))
			text_player_1.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_2.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_3.add_theme_color_override("font_color", Color(1,1,1))  # blanco
			text_player_4.add_theme_color_override("font_color", Color(1,1,1))  # blanco


func _on_confirmar_pressed() -> void:
	var n = GameData.num_jugadores
	var final_names: Array[String] = []

	# Jugador 1
	if n >= 1:
		if p1.text.strip_edges() == "":
			final_names.append("Jugador 1")
		else:
			final_names.append(p1.text)

	# Jugador 2
	if n >= 2:
		if p2.text.strip_edges() == "":
			final_names.append("Jugador 2")
		else:
			final_names.append(p2.text)

	# Jugador 3
	if n >= 3:
		if p3.text.strip_edges() == "":
			final_names.append("Jugador 3")
		else:
			final_names.append(p3.text)

	# Jugador 4
	if n >= 4:
		if p4.text.strip_edges() == "":
			final_names.append("Jugador 4")
		else:
			final_names.append(p4.text)

	GameData.player_names = final_names

	print("Nombres actualizados:", GameData.player_names)

	# Ir a la pantalla de juego
	get_tree().change_scene_to_file("res://Opciones/Menú principal/Personalizar.tscn")
