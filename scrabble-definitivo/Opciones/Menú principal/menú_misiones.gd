extends Control

const MENU_SCENE := preload ("res://Opciones/Menú principal/Menú principal.tscn")

@onready var contenedor = $VBoxContainer/Label/ScrollContainer/ListaMisiones

func _ready():
	actualizar_ui()


# Actualiza la interfaz de misiones
func actualizar_ui():
	# Limpiar contenedor
	if contenedor:
		for hijo in contenedor.get_children():
			hijo.queue_free()
	else:
		push_error("Contenedor de misiones no encontrado")
		return

	# Acceder a estadísticas globales
	var stats = SaveGame.estadisticas
	MisionLoadable.actualizar_misiones(stats)

	# Mostrar cada misión
	for key in MisionLoadable.misiones.keys():
		var m = MisionLoadable.misiones[key]

		# Contenedor de la fila
		var fila = HBoxContainer.new()
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.custom_minimum_size = Vector2(0, 30) # Alto de la fila

		# Nombre de la misión
		var label_nombre = Label.new()
		label_nombre.text = m["descripcion"]
		label_nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(label_nombre)

		# Barra de progreso
		var barra = ProgressBar.new()
		barra.min_value = 0
		barra.max_value = m["objetivo"]
		barra.value = m["progreso"]
		barra.show_percentage = true
		barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(barra)

		# Estado (✅ o ❌)
		var label_estado = Label.new()
		label_estado.text = "✅" if m["completada"] else "❌"
		fila.add_child(label_estado)

		# Recompensa en monedas
		var label_monedas = Label.new()
		label_monedas.text = "+%d 💰" % m["recompensa"]
		fila.add_child(label_monedas)
		contenedor.add_child(fila)
			# Actualizar UI si existe
	if get_tree().current_scene.has_method("actualizar_ui_monedas"):
		get_tree().current_scene.actualizar_ui_monedas()



func _on_volver_pressed() -> void:
	$SFXPlayer.play()
	#Cambia a la escena donde eliges 1,2,3 o 4 jugadores
	#get_tree().change_scene_to_file("res://Opciones/Menú Principal/MenuMultijugadores.tscn")
	queue_free()
