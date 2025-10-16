extends Control

func salir():
	get_tree().paused = false

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")

func _on_tutorial_pressed() -> void:
	var t = TUTORIAL_SCENE.instantiate()
	get_tree().current_scene.add_child(t)
