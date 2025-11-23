extends Control

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")
const CREDITS_SCENE := preload("res://Créditos/Créditos.tscn")
const MENU_JUGADORES_SCENE := preload("res://Opciones/Menú principal/MenuMultijugadores.tscn")
const CUENTA_SCENE := preload ("res://addons/talo/samples/authentication/authentication.tscn")

func _on_tutorial_pressed() -> void:
	$SFXPlayer.play()
	var t = TUTORIAL_SCENE.instantiate()
	get_tree().current_scene.add_child(t)

func _on_créditos_pressed() -> void:
	$SFXPlayer.play()
	var t = CREDITS_SCENE.instantiate()
	get_tree().current_scene.add_child(t)

func _on_salir_pressed() -> void:
	get_tree().quit()

func _on_jugar_pressed() -> void:
	$SFXPlayer.play()
	#Cambia a la escena donde eliges 1,2,3 o 4 jugadores
	#get_tree().change_scene_to_file("res://Opciones/Menú Principal/MenuMultijugadores.tscn")
	get_tree().change_scene_to_packed(MENU_JUGADORES_SCENE)


func _on_cuenta_pressed() -> void:
	$SFXPlayer.play()
	var t = CUENTA_SCENE.instantiate()
	get_tree().current_scene.add_child(t)
