extends Control

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")
const MENU_SCENE := preload("res://Opciones/Menú principal/Menú principal.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_packed(TUTORIAL_SCENE)

func _on_salir_pressed() -> void:
	queue_free()

func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_packed(MENU_SCENE)
