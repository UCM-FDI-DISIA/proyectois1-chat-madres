extends ColorRect

@export var duracion_fade: float = 0.25
@export var color_final: Color = Color(0.42, 0.22, 1.0, 0.341)
@export var mantener_visible: float = 0.01

func _ready() -> void:
		color = Color(color_final.r, color_final.g, color_final.b, 0.0)

func mostrar_con_fundido() -> void:
	var t := create_tween()
	t.tween_property(self, "color:a", 1.0, duracion_fade)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_interval(mantener_visible)
	t.tween_property(self, "color:a", 0.0, duracion_fade)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
