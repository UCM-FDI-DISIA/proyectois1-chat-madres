# Stats.gd
extends Node

var points: int = 0
var exp: int = 0
var games_played: int = 0
var e_points: int = 0
var e_exp: int = 0
var e_games_played: int = 0

func add_points(amount: int) -> void:
	e_points += amount

func add_exp(amount: int) -> void:
	e_exp += amount

func add_game() -> void:
	e_games_played += 1
	print(e_games_played)

func reset() -> void:
	points = 0
	exp = 0
	games_played = 0
