extends Control

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")
const JUEGO_SCENE := preload("res://Juego/Pantalla de juego.tscn")
const CONTROLES_SCENE := preload("res://Opciones/Tutorial/controles.tscn")

func _on_tutorial_pressed() -> void:
	$SFXPlayer.play()
	var tutorial = TUTORIAL_SCENE.instantiate()  # instanciamos
	add_child(tutorial)  # se agrega a la escena actual
	
func _on_controles_pressed() -> void:
	$SFXPlayer.play()
	var controles = CONTROLES_SCENE.instantiate()  # instanciamos
	add_child(controles)  # se agrega a la escena actual
	
func _on_salir_pressed() -> void:
	$SFXPlayer.play()
	queue_free()

func _on_button_4_pressed() -> void:
	$SFXPlayer.play()
	queue_free()
	# Obtenemos el nodo raíz de la escena actual (el que tiene el script de juego)
	var juego_node = get_tree().current_scene

	if juego_node and juego_node.has_method("finalizar_partida"):
		await juego_node.finalizar_partida()  # llamamos a la función y esperamos a que termine
	else:
		print("⚠️ No se encontró el método 'finalizar_partida' en la escena actual.")
