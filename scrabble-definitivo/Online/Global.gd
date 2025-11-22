extends Node

func _ready():
	
  SilentWolf.configure({
	"api_key": "djQ8M0Ouqx6xZUY1SzZXp7RXcQCQ9vZG8NUXBtfM",
	"game_id": "Scrabble",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://Opciones/Menú principal/Menú principal.tscn"
  })

  SilentWolf.configure_auth({
		"redirect_to_scene": "res://Opciones/Menú principal/Menú principal.tscn",
		"login_scene": "res://addons/silent_wolf/Auth/Login.tscn",
		"email_confirmation_scene": "res://addons/silent_wolf/Auth/ConfirmEmail.tscn",
		"reset_password_scene": "res://addons/silent_wolf/Auth/ResetPassword.tscn",
		"session_duration_seconds": 0,
		"saved_session_expiration_days": 30
})
