extends Control

@onready var error = $Label

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")
const CREDITS_SCENE := preload("res://Créditos/Créditos.tscn")
const MENU_JUGADORES_SCENE := preload("res://Opciones/Menú principal/MenuMultijugadores.tscn")
const CUENTA_SCENE := preload ("res://addons/talo/samples/authentication/authentication.tscn")
const CONTROLES_SCENE := preload ("res://Opciones/Tutorial/controles.tscn")
const GUARDAR_SCENE := preload ("res://Online/pantalla_guardado.tscn")
const MISIONES_SCENE := preload ("res://Escena_misiones/Misiones.tscn")
const TIENDA_SCENE := preload ("res://Tienda/Tienda.tscn")
const DONAR_SCENE := preload ("res://Opciones/donación.tscn")

func show_error_message():
	error.text = "Inicia sesión para poder acceder a esto"
	error.visible = true
	await get_tree().create_timer(2.0).timeout
	error.visible = false

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


func _on_controles_pressed() -> void:
	$SFXPlayer.play()
	var t = CONTROLES_SCENE.instantiate()
	get_tree().current_scene.add_child(t)


func _on_personalizar_partida_pressed() -> void:
	$SFXPlayer.play()
	get_tree().change_scene_to_file("res://Opciones/Menú principal/MenuTematica.tscn")


func _on_guardar_pressed() -> void:
	$SFXPlayer.play()
	if Talo.current_player:
		var t = GUARDAR_SCENE.instantiate()
		get_tree().current_scene.add_child(t)
	show_error_message()


func _on_misiones_pressed() -> void:
	$SFXPlayer.play()
	if Talo.current_player:
		var t = MISIONES_SCENE.instantiate()
		get_tree().current_scene.add_child(t)
	show_error_message()


func _on_tienda_pressed() -> void:
	$SFXPlayer.play()
	if Talo.current_player:
		var t = TIENDA_SCENE.instantiate()
		get_tree().current_scene.add_child(t)
	show_error_message()


func _on_donacion_pressed() -> void:
	$SFXPlayer.play()
	var t = DONAR_SCENE.instantiate()
	get_tree().current_scene.add_child(t)
