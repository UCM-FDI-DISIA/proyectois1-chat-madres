extends Node

func _ready():
	
  SilentWolf.configure({
	"api_key": "djQ8M0Ouqx6xZUY1SzZXp7RXcQCQ9vZG8NUXBtfM",
	"game_id": "Scrabble",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/MainPage.tscn"
  })
