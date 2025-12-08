extends Control   # o Node2D, según tu escena

func _ready():
	set_process_input(true)

func _input(event):
	# Si se presiona cualquier tecla
	if event is InputEventKey and event.pressed:
		cerrar_creditos()

	# Si se hace clic con el ratón
	if event is InputEventMouseButton and event.pressed:
		cerrar_creditos()

func cerrar_creditos():
	# Si la escena vuelve al menú:
	get_tree().change_scene_to_file("res://Opciones/Menú principal/Menú principal.tscn")
