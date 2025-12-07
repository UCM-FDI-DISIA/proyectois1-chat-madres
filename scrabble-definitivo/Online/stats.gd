# Stats.gd
extends Node

var points: int = 0
var exp: int = 0
var games_played: int = 0

func add_points(amount: int) -> void:
	points += amount

func add_exp(amount: int) -> void:
	exp += amount

func add_game() -> void:
	games_played += 1
	print(games_played)

func reset() -> void:
	points = 0
	exp = 0
	games_played = 0
