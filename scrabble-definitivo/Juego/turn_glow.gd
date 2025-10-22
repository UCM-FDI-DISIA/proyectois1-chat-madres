extends Control

@export var color_morado: Color = Color(0.7, 0.3, 1.0, 1.0)
@export var thickness_px: int = 12
@export var layers: int = 6
@export var layer_step_alpha: float = 0.14

var strength: float = 0.0  # 0..1

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 10000

func set_strength(v: float) -> void:
	strength = clampf(v, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	if strength <= 0.001:
		return

	var r := Rect2(Vector2.ZERO, size)
	var base_alpha := 0.9 * strength
	var width := float(thickness_px)

	# Borde principal
	draw_rect(r, Color(color_morado.r, color_morado.g, color_morado.b, base_alpha), false, width, true)

	# Halos exteriores (glow suave)
	for i in range(1, layers + 1):
		var a := max(0.0, base_alpha - float(i) * layer_step_alpha * strength)
		if a <= 0.01:
			break
		var grow := float(i) * 2.0
		var w := width + float(i) * 2.0
		draw_rect(r.grow(grow), Color(color_morado.r, color_morado.g, color_morado.b, a), false, w, true)
