extends Control

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")
const MENU_SCENE := preload("res://Opciones/Menú principal/Menú principal.tscn")

func _on_tutorial_pressed() -> void:
	var t = TUTORIAL_SCENE.instantiate()
	get_tree().current_scene.add_child(t)

func _on_salir_pressed() -> void:
		queue_free()

func _on_button_4_pressed() -> void:
	var t = MENU_SCENE.instantiate()
	get_tree().current_scene.add_child(t)
