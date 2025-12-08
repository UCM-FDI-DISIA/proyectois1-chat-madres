class_name LoadableStats
extends TaloLoadable

@export var username: String = "username"

@onready var save_label = $Label
@onready var button = $Button

func _ready() -> void:
	super()
	_update_button_text()
	
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
	_update_button_text()

func _on_button_pressed() -> void:
	# Sumar los stats pendientes
	Stats.points += Stats.e_points
	Stats.exp += Stats.e_exp
	Stats.games_played += Stats.e_games_played

	# Resetear stats pendientes
	Stats.e_points = 0
	Stats.e_exp = 0
	Stats.e_games_played = 0

	show_save_message()
	_update_button_text()

	await Talo.saves.update_current_save()
	print("Partida guardada -> Points:", Stats.points, " EXP:", Stats.exp, " Games:", Stats.games_played)

func _on_identified(_player: TaloPlayer) -> void:
	var saves = await Talo.saves.get_saves()
	if saves.is_empty():
		await Talo.saves.create_save("save", {})
	await Talo.saves.choose_save(Talo.saves.all.front())
	_update_button_text()

func _update_button_text() -> void:
	if button:
		button.text = "Puntos: %s | EXP: %s | Partidas jugadas: %s\nPlayer: %s\n¿Deseas guardar la partida?" % [
			Stats.points,
			Stats.exp,
			Stats.games_played,
			Talo.current_alias.identifier
		]

func show_save_message():
	save_label.text = "✅ Partida guardada"
	save_label.visible = true
	await get_tree().create_timer(2.0).timeout
	save_label.visible = false

func _on_salir_pressed() -> void:
	queue_free()
