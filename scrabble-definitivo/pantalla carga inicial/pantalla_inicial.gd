extends Control

@export var escena_a_cargar: String = "res://menu_principal.tscn"
var loading := false

func _ready():
	# Inicia la carga en segundo plano
	var err = ResourceLoader.load_threaded_request(escena_a_cargar)
	if err == OK:
		loading = true

func _process(_delta):
	if loading:
		var load_status = []
		var result = ResourceLoader.load_threaded_get_status(escena_a_cargar, load_status)
		if result == ResourceLoader.THREAD_LOAD_LOADED:
			var escena = ResourceLoader.load_threaded_get(escena_a_cargar)
			get_tree().change_scene_to_packed(escena)
			loading = false
