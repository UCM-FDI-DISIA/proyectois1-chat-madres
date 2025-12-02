# PantallaCarga.gd
extends Control

@export var escena_destino: String = "res://Juego/Pantalla de juego.tscn"

func _ready():
	# Iniciar la carga asíncrona
	ResourceLoader.load_threaded_request(escena_destino)
	# Preparar indicadores visuales
	$ProgressBar.value = 0

	set_process(true)

func _process(_delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(escena_destino, progress)
	if progress.size() > 0:
		$ProgressBar.value = progress[0] * 100

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed = ResourceLoader.load_threaded_get(escena_destino)
		if packed and packed is PackedScene:
			get_tree().change_scene_to_packed(packed)
		else:
			push_error("Error: recurso cargado no es escena válida.")
		set_process(false)
