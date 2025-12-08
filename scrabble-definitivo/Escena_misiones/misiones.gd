class_name misiones
extends TaloLoadable

@export var username: String = "username"

@onready var button = $Button
@onready var barra_exp: ProgressBar = $BarraExp

func _ready() -> void:
	super()
	_actualizar_barras()
	Talo.players.identified.connect(_on_identified)
	Talo.players.identify("username", username)

func register_fields() -> void:
	register_field("points", Stats.points)
	register_field("exp", Stats.exp)
	register_field("games_played", Stats.games_played)

func on_loaded(data: Dictionary) -> void:
	Stats.points = str(data.get("points", 0)).to_int()
	Stats.exp = str(data.get("exp", 0)).to_int()
	Stats.games_played = str(data.get("games_played", 0)).to_int()
	_actualizar_barras()

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

	_actualizar_barras()

func _on_identified(_player: TaloPlayer) -> void:
	var saves = await Talo.saves.get_saves()
	if saves.is_empty():
		await Talo.saves.create_save("save", {})
	await Talo.saves.choose_save(Talo.saves.all.front())
	_actualizar_barras()

func _actualizar_barras() -> void:

	# Barra de EXP (1 por punto + 100 por partida)
	var total_exp = Stats.exp
	barra_exp.value = total_exp
	barra_exp.max_value = 1000


func _on_salir_pressed() -> void:
	queue_free()
