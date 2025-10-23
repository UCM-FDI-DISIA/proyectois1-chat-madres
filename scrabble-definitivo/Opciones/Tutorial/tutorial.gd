extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hijos = getchildren()
		for i in range (hijos.size() -1, -1, -1):
			if hijos[i] is Sprite 2D and hijos[i].visible:
				hijos[i].queue_free()
				break
