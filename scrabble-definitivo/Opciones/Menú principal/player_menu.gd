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
	# Recoger solo los nombres necesarios
	var n = GameData.num_jugadores
	var final_names = []

	if n >= 1: final_names.append(p1.text)
	if n >= 2: final_names.append(p2.text)
	if n >= 3: final_names.append(p3.text)
	if n >= 4: final_names.append(p4.text)

	GameData.player_names = final_names

	print("Nombres actualizados:", GameData.player_names)

	# ir a la pantalla de juego
	get_tree().change_scene_to_file("res://Opciones/Menú principal/Personalizar.tscn")
