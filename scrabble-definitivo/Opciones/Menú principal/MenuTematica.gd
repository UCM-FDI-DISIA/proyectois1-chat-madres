extends Control

func _ready():
	print("Script listo, _ready() ejecutado")
	# Conectar señales manualmente (por si en la escena no aparecen)
	$VBoxContainer/GridContainer/NAVIDAD.pressed.connect(_on_btn_navidad_pressed)
	$VBoxContainer/GridContainer/NATURALEZA.pressed.connect(_on_btn_naturaleza_pressed)
	$VBoxContainer/GridContainer/CIENCIA.pressed.connect(_on_btn_ciencia_pressed)
	$VBoxContainer/GridContainer/ARTE.pressed.connect(_on_btn_arte_pressed)

func _on_btn_navidad_pressed():
	GameData.selected_theme = "navidad"
	_go_to_multiplayer()

func _on_btn_naturaleza_pressed():
	GameData.selected_theme = "naturaleza"
	_go_to_multiplayer()

func _on_btn_ciencia_pressed():
	GameData.selected_theme = "ciencia"
	_go_to_multiplayer()

func _on_btn_arte_pressed():
	GameData.selected_theme = "arte"
	_go_to_multiplayer()

func _go_to_multiplayer():
	print("CAMBIO DE ESCENA ACTIVADO")
	get_tree().change_scene_to_file("res://Opciones/Menú principal/MenuMultijugadores.tscn")
