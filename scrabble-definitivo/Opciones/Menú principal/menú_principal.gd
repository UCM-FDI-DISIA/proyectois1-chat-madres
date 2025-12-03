extends Control

const TUTORIAL_SCENE := preload("res://Opciones/Tutorial/Tutorial.tscn")
const CREDITS_SCENE := preload("res://Créditos/Créditos.tscn")
const MENU_JUGADORES_SCENE := preload("res://Opciones/Menú principal/MenuMultijugadores.tscn")
const CUENTA_SCENE := preload ("res://addons/talo/samples/authentication/authentication.tscn")
const CONTROLES_SCENE := preload ("res://Opciones/Tutorial/controles.tscn")
const DONACION_SCENE := preload ("res://Créditos/Donacion.tscn")
const MISIONES_SCENE := preload ("res://Opciones/Menú principal/MenúMisiones.tscn")

func _ready():
	actualizar_ui_monedas()

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
	SaveGame.sumar_partida()
	print("Partidas jugadas totales: ", SaveGame.estadisticas["PartidasJugadas"])
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


func _on_donacion_pressed() -> void:
	var t = DONACION_SCENE.instantiate()
	get_tree().current_scene.add_child(t)


func _on_misiones_pressed() -> void:
	$SFXPlayer.play()
	pass # Replace with function body.	$SFXPlayer.play()
	var t = MISIONES_SCENE.instantiate()
	get_tree().current_scene.add_child(t)

func actualizar_ui_monedas():
	var label_monedas = get_node("/root/MenúPrincipal/LabelMonedas")
	if label_monedas:
		label_monedas.text = str(SaveGame.estadisticas["Monedas"]) + " 💰"
	else:
		push_warning("Label de monedas no encontrado")
