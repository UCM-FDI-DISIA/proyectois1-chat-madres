extends Control

const MENU_SCENE := preload("res://Opciones/Menú principal/Menú principal.tscn")

@onready var label_titulo: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelTitulo
@onready var boton_menu: Button = $CenterContainer/PanelContenido/VBoxContainer/BotonMenu

func _ready():
	label_titulo.text = "FIN DE LA PARTIDA"
	boton_menu.text = "Volver al menú principal"

	boton_menu.pressed.connect(_on_boton_menu_pressed)

func _on_boton_menu_pressed():
	get_tree().change_scene_to_packed(MENU_SCENE)
