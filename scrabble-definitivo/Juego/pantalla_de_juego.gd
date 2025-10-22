extends Control

@onready var turn_glow: Control = $TurnGlow

var es_mi_turno := false
var pulse_tween: Tween

func _ready() -> void:
	# Prueba: enciende al iniciar para ver el efecto
	set_turno(true)

func set_turno(mi_turno: bool) -> void:
	es_mi_turno = mi_turno
	_fade_and_pulse()

func _fade_and_pulse() -> void:
	# corta pulsos anteriores
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()

	var from_val := (turn_glow as Node).get("strength") if turn_glow.has_method("set_strength") else 0.0
	# Si no puedes leer strength del hijo, empieza desde 0
	if typeof(from_val) != TYPE_FLOAT:
		from_val = 0.0

	var to_val := 1.0
	if not es_mi_turno:
		to_val = 0.0

	# Fade in/out
	var t := create_tween()
	t.tween_method(func(v): turn_glow.call("set_strength", v), float(from_val), float(to_val), 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Respiración sutil cuando es tu turno
	if es_mi_turno:
		pulse_tween = create_tween().set_loops()
		pulse_tween.tween_method(func(v): turn_glow.call("set_strength", v), 1.0, 0.75, 1.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pulse_tween.tween_method(func(v): turn_glow.call("set_strength", v), 0.75, 1.0, 1.1)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
