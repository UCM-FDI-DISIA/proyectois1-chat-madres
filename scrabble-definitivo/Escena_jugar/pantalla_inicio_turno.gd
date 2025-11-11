extends Control

signal opcion_elegida(opcion: String)

func _ready() -> void:
	$VBoxContainer/ButtonColocar.connect("pressed", Callable(self, "_on_colocar_pressed"))
	$VBoxContainer/ButtonIntercambiar.connect("pressed", Callable(self, "_on_intercambiar_pressed"))
	$VBoxContainer/ButtonPasar.connect("pressed", Callable(self, "_on_pasar_pressed"))

func _on_colocar_pressed() -> void:
	emit_signal("opcion_elegida", "colocar")
	queue_free()

func _on_intercambiar_pressed() -> void:
	emit_signal("opcion_elegida", "intercambiar")
	queue_free()

func _on_pasar_pressed() -> void:
	emit_signal("opcion_elegida", "pasar")
	queue_free()
