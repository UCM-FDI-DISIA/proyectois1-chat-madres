extends Control

var es_mi_turno: bool = false

const OPTIONS_SCENE := preload("res://Opciones/opciones.tscn")

func _ready() -> void:
	set_turno(true)
	$PantallaError.visible = false
	$PantallaError.modulate.a = 0
	$MensajeError.visible = false
# ===========================
# 🔹 Actualizar contador de bolsa
# ===========================
func actualizar_contador_bolsa() -> void:
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		push_warning("No se encontró el nodo Atril")
		return

	var label := get_node_or_null("ContadorBolsa")
	if label == null:
		push_warning("No se encontró el Label ContadorBolsa")
		return

	if atril.bolsa:
		label.text = str(atril.bolsa.quedan())  # 👈 Solo el número
	else:
		label.text = "0"

# ===========================
# 🔹 Control de turno
# ===========================
func set_turno(mi_turno: bool) -> void:
	es_mi_turno = mi_turno
	if es_mi_turno:
		$ColorRect.mostrar_con_fundido()
		var tablero := get_tree().current_scene.get_node_or_null("Board")
		if tablero and tablero.has_method("empezar_turno"):
			tablero.empezar_turno()
		actualizar_contador_bolsa() # 👈 aquí

func _on_opciones_pressed() -> void:
	var t = OPTIONS_SCENE.instantiate()
	get_tree().current_scene.add_child(t)

# ===========================
# 🔹 BOTÓN "FINALIZAR TURNO"
# ===========================

func _on_finalizar_turno_pressed() -> void:
	if not es_mi_turno:
		return

	var tablero := get_tree().current_scene.get_node_or_null("Board")
	if tablero == null:
		push_warning("No se encontró el nodo 'Board'")
		return

	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		push_warning("No se encontró el nodo 'PanelContainer' (atril)")
		return

	# Bloquear la colocación
	es_mi_turno = false

	# Bloquear botones del atril
	if atril:
		for child in atril.get_children():
			if child is Button:
				child.disabled = true

	# Atenuar el tablero
	if tablero:
		tablero.modulate = Color(1, 1, 1, 0.6)

	# Validar jugada (devuelve bool)
	var ok := await _validar_jugada(tablero)
	
	if ok and tablero.has_method("limpiar_fichas_turno"):
		tablero.limpiar_fichas_turno()

	# Reponer fichas colocadas
	if atril and atril.has_method("reponer_fichas_colocadas"):
		atril.reponer_fichas_colocadas()

	# Si es válida, limpiamos estado de turno en el Board
	if ok and tablero.has_method("limpiar_fichas_turno"):
		tablero.limpiar_fichas_turno()

	# Reactivar turno SIEMPRE para permitir seguir jugando/corrigiendo
	_reactivar_turno()
	
	if atril and atril.has_method("reponer_fichas_colocadas"):
		atril.reponer_fichas_colocadas()
		actualizar_contador_bolsa() # 👈 correcto


# ===========================
# 🔹 VALIDACIÓN DE JUGADA
# ===========================
func _validar_jugada(tablero: Node) -> bool:
	if tablero == null:
		return false

	var dict = tablero.get("celdas_ocupadas")
	if typeof(dict) != TYPE_DICTIONARY:
		return false

	var fichas_colocadas: Array = tablero.get("fichas_turno_actual")
	if fichas_colocadas == null or fichas_colocadas.is_empty():
		print("No hay fichas colocadas este turno.")
		await get_tree().create_timer(0.3).timeout
		return false

	var es_primer_turno_local: bool = true
	if tablero.has_method("get"):
		es_primer_turno_local = tablero.get("es_primer_turno")

	# Reglas de conexión/centro
	if es_primer_turno_local:
		if tablero.has_method("_toca_centro_en_turno") and not tablero._toca_centro_en_turno():
			print("Primera jugada inválida: debe tocar la casilla central.")
			if tablero.has_method("devolver_fichas_turno"):
				tablero.devolver_fichas_turno()
			await get_tree().create_timer(0.3).timeout
			return false
	else:
		if tablero.has_method("_hay_conexion_con_tablero_previo") and not tablero._hay_conexion_con_tablero_previo():
			print("Jugada inválida: no está conectada a palabras ya colocadas.")
			if tablero.has_method("devolver_fichas_turno"):
				tablero.devolver_fichas_turno()
			await get_tree().create_timer(0.3).timeout
			return false

	# Reconstruye palabras completas por si acaso (evitar prefijos)
	if tablero.has_method("_reconstruir_palabras_turno"):
		tablero._reconstruir_palabras_turno()

	# Comprobar repetidas
	if tablero.has_method("es_palabra_repetida"):
		for palabra in tablero.palabras_turno_actual:
			if tablero.es_palabra_repetida(palabra):
				print("Palabra repetida:", palabra)
				if tablero.has_method("devolver_fichas_turno"):
					tablero.devolver_fichas_turno()
				await get_tree().create_timer(0.3).timeout
				return false

	# Comprobar en diccionario RAE
	if tablero.has_method("es_palabra_valida_RAE"):
		for palabra in tablero.palabras_turno_actual:
			if not tablero.es_palabra_valida_RAE(palabra):
				print("Palabra no válida según RAE:", palabra)
				mostrar_error("Palabra no válida: %s" % palabra)
				if tablero.has_method("devolver_fichas_turno"):
					tablero.devolver_fichas_turno()
				await get_tree().create_timer(0.3).timeout
				return false

	print("Jugada válida según reglas de Scrabble.")
	await get_tree().create_timer(0.6).timeout

	# Registrar palabras nuevas
	if tablero.has_method("registrar_palabras_turno_actual"):
		tablero.registrar_palabras_turno_actual()

	# Marcar fin del primer turno
	if es_primer_turno_local:
		if tablero.has_method("set"):
			tablero.set("es_primer_turno", false)
		else:
			tablero.es_primer_turno = false
			
	return true

# ===========================
# 🔹 REACTIVAR TURNO
# ===========================
func _reactivar_turno() -> void:
	var tablero := get_tree().current_scene.get_node_or_null("Board")
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")

	if atril:
		for child in atril.get_children():
			if child is Button:
				child.disabled = false

	if tablero:
		tablero.modulate = Color(1, 1, 1, 1)

	es_mi_turno = true
	print("Turno reactivado.")

# ===========================
# 🔹 INTERCAMBIAR FICHAS
# ===========================

func _on_intercambiar_fichas_pressed() -> void:
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		mostrar_error("No se encontró el atril.")
		return

	# Pedir al jugador seleccionar las fichas a intercambiar
	print("Selecciona las fichas que deseas intercambiar (clic).")

	# Desactivar tablero mientras se eligen fichas
	var tablero := get_tree().current_scene.get_node_or_null("Board")
	if tablero:
		tablero.modulate = Color(1, 1, 1, 0.5)
		tablero.set_process_input(false)

	# Esperamos selección de fichas
	var fichas_a_cambiar: Array = await atril.seleccionar_fichas_para_intercambio()

	if fichas_a_cambiar.is_empty():
		mostrar_error("No seleccionaste fichas para intercambiar.")
		if tablero:
			tablero.modulate = Color(1, 1, 1, 1)
			tablero.set_process_input(true)
		return

	# Ejecutar el intercambio
	atril.intercambiar_fichas(fichas_a_cambiar)

	# Reactivar tablero y actualizar contador
	if tablero:
		tablero.modulate = Color(1, 1, 1, 1)
		tablero.set_process_input(true)

	actualizar_contador_bolsa()
	print("Fichas intercambiadas correctamente.")


# ===========================
# REORDENAR FICHAS
# ===========================
func _on_reordenar_fichas_pressed() -> void:
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		mostrar_error("No se encontró el atril.")
		return

	var tablero := get_tree().current_scene.get_node_or_null("Board")
	if tablero:
		tablero.modulate = Color(1, 1, 1, 0.5)
		tablero.set_process_input(false)

	await atril.seleccionar_fichas_para_reordenar()

	if tablero:
		tablero.modulate = Color(1, 1, 1, 1)
		tablero.set_process_input(true)

	print("🔁 Reordenamiento completado.")

# ===========================
# 🔹 MENSAJE DE ERROR
# ===========================
func mostrar_error(mensaje: String) -> void:
	var pantalla := $PantallaError
	var label := $MensajeError

	# Preparar nodos
	pantalla.visible = true
	label.visible = true
	label.text = mensaje
	pantalla.color.a = 0.0  # Empezamos invisible

	# Duraciones
	var duracion_fade := 0.15
	var mantener_visible := 0.2

	# Tween
	var t := create_tween()
	t.tween_property(pantalla, "color:a", 0.6, duracion_fade).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_interval(mantener_visible)
	t.tween_property(pantalla, "color:a", 0.0, duracion_fade).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(Callable(self, "_ocultar_error"))

func _ocultar_error() -> void:
	$PantallaError.visible = false
	$MensajeError.visible = false
