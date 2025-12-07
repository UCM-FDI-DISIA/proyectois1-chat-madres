extends Control


@onready var fondo = $TextureRect  # TextureRect que pusiste como fondo
@onready var titulo = $VBox_Botones/titulo


func _ready():
	_actualizar_fondo()

# --- Fondo dinámico según temática ---
func _actualizar_fondo():
	match GameData.selected_theme:
		"navidad":
			fondo.texture = load("res://Opciones/FONDOS TEMATICAS/NAVIDADFONDOMULTIJUGADOR.jpg")
			titulo.add_theme_color_override("font_color", Color(1, 1, 1))  # blanco
		"naturaleza":
			fondo.texture = load("res://Opciones/FONDOS TEMATICAS/NATURALEZAMULTI.jpg")
		"ciencia":
			fondo.texture = load("res://Opciones/FONDOS TEMATICAS/CIENCIAMULTI.jpg")
			titulo.add_theme_color_override("font_color", Color(1, 1, 1))  # blanco
		"arte":
			fondo.texture = load("res://Opciones/FONDOS TEMATICAS/ARTEMULTI.jpg")
			titulo.add_theme_color_override("font_color", Color(1, 1, 1))  # blanco
		_:
			fondo.texture = load("res://Opciones/Menú principal/fondo menu multijugador.png")  # Fondo neutro
			titulo.add_theme_color_override("font_color", Color(0, 0, 0))  # negro
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
