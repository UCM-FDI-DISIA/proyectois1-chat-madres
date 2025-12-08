class_name tienda
extends TaloLoadable

@export var username: String = "username"

@onready var button = $Button
@onready var contenedor = $ScrollContainer/VBoxContainer
@onready var exp_label = $Label
@onready var player = $AudioStreamPlayer2D

# Lista de canciones (nombre, coste de EXP, ruta del archivo)
var canciones = [
	{"nombre":"Dummy", "coste":0, "ruta":"res://Música/Dummy.ogg"},
	{"nombre":"Anticipation", "coste":100, "ruta":"res://Música/Anticipation.ogg"},
	{"nombre":"Bar", "coste":200, "ruta":"res://Música/Bar.ogg"},
	{"nombre":"Date", "coste":300, "ruta":"res://Música/Date.ogg"},
	{"nombre":"Ghost fight", "coste":400, "ruta":"res://Música/Ghost fight.ogg"},
	{"nombre":"Hi", "coste":500, "ruta":"res://Música/Hi.ogg"},
	{"nombre":"Home", "coste":600, "ruta":"res://Música/Home.ogg"},
	{"nombre":"Once upon a time", "coste":700, "ruta":"res://Música/Once upon a time.ogg"},
	{"nombre":"Reunited", "coste":800, "ruta":"res://Música/Reunited.ogg"},
	{"nombre":"Ruins", "coste":900, "ruta":"res://Música/Ruins.ogg"},
	{"nombre":"Spider dance", "coste":1000, "ruta":"res://Música/Spider-Dance.ogg"},
]

var seleccion_actual := ""  # Nombre de la canción seleccionada

func _ready():
	super()
	Talo.players.identified.connect(_on_identified)
	Talo.players.identify("username", username)
	_actualizar_ui()

func register_fields() -> void:
	register_field("points", Stats.points)
	register_field("exp", Stats.exp)
	register_field("games_played", Stats.games_played)

func on_loaded(data: Dictionary) -> void:
	Stats.points = str(data.get("points", 0)).to_int()
	Stats.exp = str(data.get("exp", 0)).to_int()
	Stats.games_played = str(data.get("games_played", 0)).to_int()
	_actualizar_ui()
	
func _on_button_pressed() -> void:
	# Sumar los stats pendientes
	Stats.points += Stats.e_points
	Stats.exp += Stats.e_exp
	Stats.games_played += Stats.e_games_played

	# Resetear stats pendientes
	Stats.e_points = 0
	Stats.e_exp = 0
	Stats.e_games_played = 0

	await Talo.saves.update_current_save()
	print("Partida guardada -> Points:", Stats.points, " EXP:", Stats.exp, " Games:", Stats.games_played)

	_actualizar_ui()

func _on_identified(_player: TaloPlayer) -> void:
	var saves = await Talo.saves.get_saves()
	if saves.is_empty():
		await Talo.saves.create_save("save", {})
	await Talo.saves.choose_save(Talo.saves.all.front())
	_actualizar_ui()

func _actualizar_ui():
	exp_label.text = "Experiencia: %d" % Stats.exp


	for cancion in canciones:
		var fila = HBoxContainer.new()
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.custom_minimum_size = Vector2(0, 40)

		var nombre_label = Label.new()
		nombre_label.text = cancion["nombre"]
		nombre_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(nombre_label)

		var boton = Button.new()
		boton.text = "Seleccionar"
		boton.disabled = Stats.exp < cancion["coste"]
		boton.connect("pressed", Callable(self, "_seleccionar_cancion").bind(cancion))
		fila.add_child(boton)

		var coste_label = Label.new()
		coste_label.text = "EXP necesaria: %d" % cancion["coste"]
		fila.add_child(coste_label)

		contenedor.add_child(fila)

func _seleccionar_cancion(cancion: Dictionary):
	if Stats.exp >= cancion["coste"]:
		
		# GUARDAR LA RUTA
		Stats.musica_seleccionada = cancion["ruta"]

		seleccion_actual = cancion["nombre"]

		print("🎵 Canción seleccionada:", seleccion_actual)
		print("🧭 Ruta guardada:", Stats.musica_seleccionada)

		# Reproducir la canción
		var audio = load(Stats.musica_seleccionada) as AudioStream
		player.stream = audio
		player.play()


func _on_salir_pressed() -> void:
	queue_free()
