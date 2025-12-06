extends Control

@export_file("*.tscn")
var escena_destino: String = "res://Juego/Pantalla de Juego.tscn"

@onready var barra_progreso: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar
@onready var label_estado: Label = $CenterContainer/VBoxContainer/LabelEstado

# ⏳ Tiempo que quieres que la barra se vea al 100% antes de cambiar
const RETRASO_FINAL_LLENO: float = 0.0

var _escena_lista: bool = false
var _tiempo_despues_100: float = 0.0


func _ready() -> void:
	# Iniciar carga en segundo plano
	var err := ResourceLoader.load_threaded_request(escena_destino)
	if err != OK:
		push_error("Error al iniciar carga de escena: %s" % err)

	# Configurar barra
	if barra_progreso:
		barra_progreso.min_value = 0.0
		barra_progreso.max_value = 100.0
		barra_progreso.value = 0.0

	# Texto inicial
	if label_estado:
		label_estado.text = "Cargando partida..."

	set_process(true)


func _process(delta: float) -> void:
	# Fase 1: estamos cargando aún
	if not _escena_lista:
		var progreso: Array[float] = [0.0]
		var status := ResourceLoader.load_threaded_get_status(escena_destino, progreso)

		# Actualizar barra (aprox.)
		if barra_progreso and progreso.size() > 0:
			var v: float = clamp(progreso[0], 0.0, 1.0)
			barra_progreso.value = v * 100.0

		# Texto con puntos animados (sin porcentaje)
		if label_estado:
			var puntos := ".".repeat(int(Time.get_ticks_msec() / 350) % 4)
			label_estado.text = "Cargando partida" + puntos

		# Cuando termina la carga del hilo…
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			_escena_lista = true
			if barra_progreso:
				barra_progreso.value = 100.0  # ✅ forzamos visualmente el 100%

		# Salimos aquí, todavía no cambiamos de escena
		return

	# Fase 2: la escena YA está cargada, dejamos 0.4s mostrando 100%
	_tiempo_despues_100 += delta
	if _tiempo_despues_100 >= RETRASO_FINAL_LLENO:
		var packed: PackedScene = ResourceLoader.load_threaded_get(escena_destino)
		if packed and packed is PackedScene:
			get_tree().change_scene_to_packed(packed)
		else:
			push_error("Error cargando escena (PackedScene nulo).")

		set_process(false)
