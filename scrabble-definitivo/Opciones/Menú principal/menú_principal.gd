extends Control

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")
const CREDITS_SCENE := preload("res://Créditos/Créditos.tscn")

func _on_tutorial_pressed() -> void:
	var t = TUTORIAL_SCENE.instantiate()
	get_tree().current_scene.add_child(t)

func _on_créditos_pressed() -> void:
	var t = CREDITS_SCENE.instantiate()
	get_tree().current_scene.add_child(t)

func _on_salir_pressed() -> void:
	get_tree().quit()
