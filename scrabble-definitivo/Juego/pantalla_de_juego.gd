extends Control

var es_mi_turno: bool = false

func set_turno(mi_turno: bool) -> void:
	es_mi_turno = mi_turno
	if es_mi_turno: 
		$ColorRect.mostrar_con_fundido()

func _ready() -> void: 
	set_turno(true)

const OPTIONS_SCENE := preload("res://Opciones/opciones.tscn")
func _on_opciones_pressed() -> void:
	var t = OPTIONS_SCENE.instantiate()
	get_tree().current_scene.add_child(t)
