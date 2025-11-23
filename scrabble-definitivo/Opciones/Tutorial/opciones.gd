extends Control

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")
const MENU_SCENE := preload("res://Opciones/Menú principal/Menú principal.tscn")
const JUEGO_SCENE := preload("res://Juego/Pantalla de juego.tscn")

func _on_tutorial_pressed() -> void:
	var tutorial = TUTORIAL_SCENE.instantiate()  # instanciamos
	add_child(tutorial)  # se agrega a la escena actual

func _on_salir_pressed() -> void:
	queue_free()

func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_packed(MENU_SCENE)
