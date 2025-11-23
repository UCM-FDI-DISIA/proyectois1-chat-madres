extends Control

#Variables
var es_mi_turno: bool = false
var puntuacion_jugador_actual: int = 0
var puntuaciones: Array = []

#Constantes
const OPTIONS_SCENE := preload("res://Opciones/opciones.tscn")

# ===========================
# 🔹 Funciones del ciclo de vida
# ===========================
func _ready() -> void:
	#1 inicializar los datos del juego
	GameData.inicializar_juego()
	print("Número de jugadores:", GameData.num_jugadores)
	print("Jugador actual:", GameData.jugador_actual + 1)

	# 2. Crear el array de atriles vacíos para cada jugador
	#GameData.atriles_jugadores.clear()
	#for i in range(GameData.num_jugadores):
		#GameData.atriles_jugadores.append([])

	# 3. Generar atril inicial de cada jugador desde la misma bolsa
	#var atril = $PanelContainer/Atril

	#for i in range(GameData.num_jugadores):
		# Simular que ese jugador está robando fichas
		#GameData.jugador_actual = i

		#atril._rellenar_atril()
		#
		# Dejar el atril vacío para que no quede el del último jugador
		#
	# 4. Volver al jugador 0
	#GameData.jugador_actual = 0
	#atril.cargar_atril(GameData.atriles_jugadores[0])

	#5 Resto:
	
	# Inicializar sistema de puntuación
	inicializar_sistema_puntuacion()
	# Activar turno del primer jugador
	set_turno(true)
	actualizar_label_turno()
	
	$PantallaError.visible = false
	$PantallaError.modulate.a = 0
	$MensajeError.visible = false
	
	# --- Conexiones programáticas y robustas de botones (Godot 4.5) ---
	var btn_opciones := get_node_or_null("Opciones")
	var btn_intercambiar := get_node_or_null("IntercambiarFichas")
	var btn_finalizar := get_node_or_null("FinalizarTurno")
	var btn_reordenar := get_node_or_null("ReordenarFichas")

	if btn_opciones:
		var c_op := Callable(self, "_on_opciones_pressed")
		if not btn_opciones.is_connected("pressed", c_op):
			btn_opciones.connect("pressed", c_op)

	if btn_intercambiar:
		var c_int := Callable(self, "_on_intercambiar_fichas_pressed")
		if not btn_intercambiar.is_connected("pressed", c_int):
			btn_intercambiar.connect("pressed", c_int)

	if btn_finalizar:
		var c_fin := Callable(self, "_on_finalizar_turno_pressed")
		if not btn_finalizar.is_connected("pressed", c_fin):
			btn_finalizar.connect("pressed", c_fin)

	if btn_reordenar:
		var c_reo := Callable(self, "_on_reordenar_fichas_pressed")
		if not btn_reordenar.is_connected("pressed", c_reo):
			btn_reordenar.connect("pressed", c_reo)
	# --------------------------------------------------------

# ===========================
# 🔹 Sistema de Puntuación
# ===========================
func inicializar_sistema_puntuacion():
	puntuacion_jugador_actual = 0
	GameData.jugador_actual = 0
	puntuaciones.clear()
	
	for i in GameData.num_jugadores:
		puntuaciones.append(0)
	
	actualizar_ui_puntuacion()

func actualizar_ui_puntuacion():
	# Buscar o crear un Label para mostrar la puntuación
	var label_puntuacion = get_node_or_null("LabelPuntuacion")
	
	if label_puntuacion == null:
		# Si no existe, lo creamos
		label_puntuacion = Label.new()
		label_puntuacion.name = "LabelPuntuacion"
		label_puntuacion.add_theme_font_size_override("font_size", 24)
		label_puntuacion.add_theme_color_override("font_color", Color(1, 1, 1))
		label_puntuacion.position = Vector2(200, 50)  # Esquina superior izquierda
		add_child(label_puntuacion)
	# Actualizar texto
	label_puntuacion.text = "Jugador %d: %d puntos" % [GameData.jugador_actual + 1, puntuaciones[GameData.jugador_actual]]

func sumar_puntos(puntos: int):
	puntuaciones[GameData.jugador_actual]+= puntos
	actualizar_ui_puntuacion()
	print("Puntos sumados: %d - Total: %d" % [puntos, puntuaciones[GameData.jugador_actual]])

# ===========================
# 🔹 Actualizar LabelTurno
# ===========================
func actualizar_label_turno():
	var label = get_node_or_null("Labelturno")
	if label:
		label.text = "Turno del jugador %d" % (GameData.jugador_actual + 1)



# ===========================
# 🔹 Control de turno
# ===========================
func set_turno(mi_turno: bool) -> void:
	es_mi_turno = mi_turno
	var tablero = get_tree().current_scene.get_node_or_null("Board")
	if es_mi_turno:
		if $ColorRect and $ColorRect.has_method("mostrar_con_fundido"):
			$ColorRect.mostrar_con_fundido()
		if tablero and tablero.has_method("empezar_turno"):
			tablero.empezar_turno()
	actualizar_contador_bolsa()
	actualizar_ui_puntuacion()

#func _siguiente_jugador():
	#GameData.jugador_actual += 1
	#if GameData.jugador_actual >= GameData.num_jugadores:
		#GameData.jugador_actual = 0
		
	#actualizar_label_turno()
	#set_turno(true)

func _siguiente_jugador():
	# 1) Guardar atril del jugador que termina turno
	#var atril = get_tree().current_scene.get_node("PanelContainer/Atril")
	#if atril:
		#GameData.atriles_jugadores[GameData.jugador_actual] = atril.exportar_atril()

	# 2) Avanzar al siguiente jugador
	GameData.jugador_actual += 1
	if GameData.jugador_actual >= GameData.num_jugadores:
		GameData.jugador_actual = 0

	# 3) Cargar atril del nuevo jugador
	#if atril:
		#atril.cargar_atril(GameData.atriles_jugadores[GameData.jugador_actual])

	# 4) Actualizar UI de turno
	actualizar_label_turno()
	set_turno(true)


# ===========================
# 🔹 Actualizar contador de bolsa
# ===========================
func actualizar_contador_bolsa() -> void:
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	var label = get_node_or_null("ContadorBolsa")
	if atril == null:
		push_warning("No se encontró el nodo Atril")
		return
		
	if label == null:
		push_warning("No se encontró el Label ContadorBolsa")
		return

	if atril.bolsa and atril.bolsa.has_method("quedan"):
		label.text = str(atril.bolsa.quedan())
	else:
		label.text = "0"

# ===========================
# 🔹 Botones
# ===========================

func _on_opciones_pressed() -> void:
	var tutorial = OPTIONS_SCENE.instantiate()
	add_child(tutorial)

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

	# Bloquear la colocación, bloquear el turno
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

	if ok:
		# ✅ JUGADA VÁLIDA - CALCULAR Y SUMAR PUNTOS
		if tablero.has_method("calcular_puntuacion_turno"):
			var puntos_turno = tablero.calcular_puntuacion_turno()
			sumar_puntos(puntos_turno)
			puntuacion_jugador_actual = puntuaciones[GameData.jugador_actual]
			print("✅ Jugada válida! Sumados %d puntos. Total: %d" % [puntos_turno, puntuacion_jugador_actual])
		
		# Registrar palabras y limpiar turno
		if tablero.has_method("registrar_palabras_turno_actual"):
			tablero.registrar_palabras_turno_actual()
		
		if tablero.has_method("limpiar_fichas_turno"):
			tablero.limpiar_fichas_turno()
		
		# Marcar fin del primer turno si era el primero
		if tablero.es_primer_turno:
			tablero.es_primer_turno = false
	else:
		# ❌ JUGADA INVÁLIDA - Devolver fichas
		print("❌ Jugada inválida, devolviendo fichas...")
		if tablero.has_method("devolver_fichas_turno"):
			tablero.devolver_fichas_turno()

	# Reponer fichas colocadas SIEMPRE
	if atril and atril.has_method("reponer_fichas_colocadas"):
		atril.reponer_fichas_colocadas()
	actualizar_contador_bolsa()

	# Reactivar turno ahora es _siguiente_jugador()
	_siguiente_jugador()

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
		if tablero.has_method("empezar_turno"):
			tablero.empezar_turno()   # ← aquí se actualiza snapshot_ocupadas_previas y es_primer_turno

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

	# --- NUEVO: Mostrar mensaje en pantalla ---
	var mensaje := get_tree().current_scene.get_node_or_null("MensajeIntercambio")
	if mensaje:
		mensaje.text = "Presiona ENTER para intercambiar fichas"
		mensaje.visible = true

	# Pedir al jugador seleccionar las fichas a intercambiar
	print("Selecciona las fichas que deseas intercambiar (clic).")

	# Desactivar tablero mientras se eligen fichas
	var tablero := get_tree().current_scene.get_node_or_null("Board")
	if tablero:
		tablero.modulate = Color(1, 1, 1, 0.5)
		tablero.set_process_input(false)

	# Esperamos selección de fichas
	var fichas_a_cambiar = await atril.seleccionar_fichas_para_intercambio()

	# --- OCULTAR MENSAJE DESPUÉS ---
	if mensaje:
		mensaje.visible = false

	# Si el usuario canceló con ESC -> null
	if fichas_a_cambiar == null:
		if tablero:
			tablero.modulate = Color(1, 1, 1, 1)
			tablero.set_process_input(true)
		print("Intercambio cancelado por el usuario.")
		return

	# Si devolvió array vacío (confirmó pero no seleccionó fichas)
	if fichas_a_cambiar.is_empty():
		mostrar_error("No seleccionaste fichas para intercambiar.")
		if tablero:
			tablero.modulate = Color(1, 1, 1, 1)
			tablero.set_process_input(true)
		return

	# Ejecutar el intercambio
	if atril.has_method("intercambiar_fichas"):
		atril.intercambiar_fichas(fichas_a_cambiar)
	else:
		print("Atril no tiene método 'intercambiar_fichas'.")

	# Reactivar tablero y actualizar contador
	if tablero:
		tablero.modulate = Color(1, 1, 1, 1)
		tablero.set_process_input(true)

	actualizar_contador_bolsa()
	print("Fichas intercambiadas correctamente.")
	
	_on_finalizar_turno_pressed()

# ===========================
# REORDENAR FICHAS
# ===========================
func _on_reordenar_fichas_pressed() -> void:
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		mostrar_error("No se encontró el atril.")
		return

	var tablero := get_tree().current_scene.get_node_or_null("Board")

	# Si ya estamos en modo reordenar, pulsar otra vez cancela el modo
	if atril.modo_reordenar:
		if atril.has_method("cancelar_reordenar"):
			atril.cancelar_reordenar()
		if tablero:
			tablero.modulate = Color(1, 1, 1, 1)
			tablero.set_process_input(true)
		print("Reordenamiento cancelado (botón).")
		return

	# Si no estaba en modo reordenar, entrar en modo reordenar como antes
	if tablero:
		tablero.modulate = Color(1, 1, 1, 0.5)
		tablero.set_process_input(false)

	if atril.has_method("seleccionar_fichas_para_reordenar"):
		await atril.seleccionar_fichas_para_reordenar()
	else:
		print("Atril no tiene método 'seleccionar_fichas_para_reordenar'.")

	if tablero:
		tablero.modulate = Color(1, 1, 1, 1)
		tablero.set_process_input(true)

	print("🔁 Reordenamiento finalizado o cancelado.")

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
	



#func guardar_atril_jugador():
	#var atril = $PanelContainer/Atril
	#GameData.atriles_jugadores[GameData.jugador_actual] = atril.exportar_atril()


#func cargar_atril_jugador():
	#var atril = $PanelContainer/Atril
	#var datos = GameData.atriles_jugadores[GameData.jugador_actual]
	#atril.cargar_atril(datos)
