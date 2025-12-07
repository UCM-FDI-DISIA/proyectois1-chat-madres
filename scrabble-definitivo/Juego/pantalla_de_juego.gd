extends Control

#Variables
var es_mi_turno: bool = false
var puntuacion_jugador_actual: int = 0
var puntuaciones: Array = []
var tiempo_restante: int = 0
var turnos_sin_puntos_consecutivos: int = 0
@onready var turno_timer := $TurnoTimer
@onready var label_tiempo := $LabelTiempo

#Constantes
const OPTIONS_SCENE := preload("res://Opciones/opciones.tscn")
const END_SCENE := preload("res://Opciones/Menú principal/Pantalla de fin.tscn")


#bolsa compartida para todos los jugadores
@onready var bolsa := preload("res://scripts/BolsaFichas.gd").new()

#Variable del fondo
@onready var fondo = $fondoEspecial
@onready var color_fondo = $FondoTablero 



#lista de atriles (uno por jugador)
var atriles: Array = []


# ===========================
# 🔹 Funciones del ciclo de vida
# ===========================
func _ready() -> void:
	_actualizar_fondo()  # <-- fondo inicial
	print("¿Hay textura?", fondo.texture)
	print("Visible fondo:", fondo.visible)
	print("Visible color:", color_fondo.visible)
	print("Tamaño fondo:", fondo.size)
	
	
	#1 inicializar los datos del juego
	GameData.inicializar_juego()
	print("Número de jugadores:", GameData.num_jugadores)
	print("Jugador actual:", GameData.jugador_actual + 1)
		# === ATRIL ÚNICO EN ESCENA: PanelContainer/Atril ===
	var atril: Node = get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		push_error("No se encontró PanelContainer/Atril")
	else:
		# Inicializar array de atriles por jugador en GameData
		GameData.atriles_jugadores.clear()
		for i in range(GameData.num_jugadores):
			GameData.atriles_jugadores.append([])

		# Empezamos siempre en jugador 0
		GameData.jugador_actual = 0

		# Rellenamos el atril visual para el jugador 0
		# (el atril ya llama a _rellenar_atril() en su _ready,
		#  pero por si acaso nos aseguramos después)
		if atril.has_method("exportar_atril"):
			GameData.atriles_jugadores[0] = atril.exportar_atril()


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
	var btn_cancelar := get_node_or_null("Cancelarcolocacion")
	var btn_finalizar_partida := get_node_or_null("FinalizarPartida")

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

	if btn_cancelar:
		var c_can := Callable(self, "_on_cancelar_colocacion_pressed")
		if not btn_cancelar.is_connected("pressed", c_can):
			btn_cancelar.connect("pressed", c_can)
			
	if turno_timer:
		turno_timer.connect("timeout", Callable(self, "_on_TurnoTimer_timeout"))
	else:
		push_error("No se encontró TurnoTimer")

	if btn_finalizar_partida:
		var c_finpar := Callable(self, "_on_finalizar_partida_pressed")
		if not btn_finalizar_partida.is_connected("pressed", c_finpar):
			btn_finalizar_partida.connect("pressed", c_finpar)
	# --------------------------------------------------------


func _actualizar_fondo():
	var jugador = GameData.jugador_actual + 1  # jugador 1, 2, 3, 4
	var tema = GameData.selected_theme

	var ruta : String = ""

	if tema == "navidad":
		match jugador:
			1: ruta = "res://Opciones/FONDOS TEMATICAS/NAVIDAD1.jpg"
			2: ruta = "res://Opciones/FONDOS TEMATICAS/NAVIDADFONDOMULTIJUGADOR.jpg"
			3: ruta = "res://Opciones/FONDOS TEMATICAS/NAVIDAD3.jpg"
			4: ruta = "res://Opciones/FONDOS TEMATICAS/NAVIDAD 4.jpg"
	elif tema == "naturaleza":
		match jugador:
			1: ruta = "res://Opciones/FONDOS TEMATICAS/NATURALEZA1.jpg"
			2: ruta = "res://Opciones/FONDOS TEMATICAS/NATURALEZA2.jpg"
			3: ruta = "res://Opciones/FONDOS TEMATICAS/NATURALEZAMULTI.jpg"
			4: ruta = "res://Opciones/FONDOS TEMATICAS/NATURALEZA4.jpg"
	elif tema == "ciencia":
		match jugador:
			1: ruta = "res://Opciones/FONDOS TEMATICAS/CIENCIA1.jpg"
			2: ruta = "res://Opciones/FONDOS TEMATICAS/CIENCIA2.jpg"
			3: ruta = "res://Opciones/FONDOS TEMATICAS/CIENCIA3.jpg"
			4: ruta = "res://Opciones/FONDOS TEMATICAS/CIENCIAMULTI.jpg"
	elif tema == "arte":
		match jugador:
			1: ruta = "res://Opciones/FONDOS TEMATICAS/ARTE1.jpg"
			2: ruta = "res://Opciones/FONDOS TEMATICAS/ARTE 2.jpg"
			3: ruta = "res://Opciones/FONDOS TEMATICAS/ARTE3.jpg"
			4: ruta = "res://Opciones/FONDOS TEMATICAS/ARTEMULTI.jpg"
	else:
		# No hay temática → fondo negro
		fondo.texture = null
		color_fondo.visible = true
		fondo.visible = false
		return
	
	# Cargar la textura
	var tex = load(ruta)
	if tex != null:
		fondo.texture = tex
		fondo.visible = true
		color_fondo.visible = false





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
	var tabla = get_node_or_null("TablaPuntuacion")
	if tabla == null:
		push_error("No existe TablaPuntuacion en la escena.")
		return

	# 1️⃣ Limpiar la tabla
	for c in tabla.get_children():
		c.queue_free()

	# 2️⃣ Crear la lista indexada
	var lista = []
	for i in range(puntuaciones.size()):
		lista.append({
			"jugador": i,
			"puntos": puntuaciones[i]
		})

	# 4️⃣ Rellenar tabla
	for entry in lista:
		var fila = HBoxContainer.new()
		fila.custom_minimum_size = Vector2(350, 40)  # ancho de fila (modifícalo si quieres)

		# Izquierda: nombre de jugador
		var nombre = Label.new()
		# Usamos el nombre real del jugador
		nombre.text = GameData.player_names[entry["jugador"]]
		nombre.add_theme_font_size_override("font_size", 24)


		# Derecha: puntos (totalmente a la derecha)
		var puntos = Label.new()
		puntos.text = str(entry["puntos"])
		puntos.add_theme_font_size_override("font_size", 24)
		puntos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		puntos.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		fila.add_child(nombre)
		fila.add_child(puntos)

		# Fondo bonito (opcional)
		var fondo = ColorRect.new()
		fondo.color = Color(0, 0, 0, 0.3)
		fondo.custom_minimum_size = Vector2(350, 40)
		fondo.add_child(fila)

		tabla.add_child(fondo)


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
		var jugador_actual = GameData.jugador_actual
		var nombre_jugador = GameData.player_names[jugador_actual]
		label.text = "Turno de %s" % nombre_jugador



# ===========================
# 🔹 Control de turno
# ===========================
func set_turno(mi_turno: bool) -> void:
	es_mi_turno = mi_turno
	var tablero = get_tree().current_scene.get_node_or_null("Board")

	if es_mi_turno:
		# Mostrar color de turno
		if $ColorRect and $ColorRect.has_method("mostrar_con_fundido"):
			$ColorRect.mostrar_con_fundido()

		# Empezar turno en el tablero
		if tablero and tablero.has_method("empezar_turno"):
			tablero.empezar_turno()

		# === INICIAR TIMER ===
		if GameData.tiempo_por_turno <= 0:
			GameData.tiempo_por_turno = 30  # valor por defecto si no está definido

		tiempo_restante = GameData.tiempo_por_turno
		actualizar_ui_tiempo()

		# Configuramos el timer para contar cada segundo
		turno_timer.wait_time = 1.0
		turno_timer.one_shot = false
		turno_timer.start()

	actualizar_contador_bolsa()
	actualizar_ui_puntuacion()

func _siguiente_jugador():
	
	var atril: Node = get_tree().current_scene.get_node_or_null("PanelContainer")

	# 1) Guardar atril del jugador que termina turno
	if atril and atril.has_method("exportar_atril"):
		var estado_atril: Array = atril.exportar_atril()

		# Comprobar si TODO son null (atril vacío) → NO machacamos el guardado
		var todas_nulas := true
		for l in estado_atril:
			if l != null:
				todas_nulas = false
				break

		if not todas_nulas:
			GameData.atriles_jugadores[GameData.jugador_actual] = estado_atril
			# Opcional: debug
			#print("DEBUG Guardando atril jugador", GameData.jugador_actual, ":", estado_atril)
		else:
			#print("DEBUG NO guardo atril de jugador", GameData.jugador_actual, "(todo null)")
			pass

	# 2) Cambiar de jugador
	GameData.jugador_actual += 1
	if GameData.jugador_actual >= GameData.num_jugadores:
		GameData.jugador_actual = 0

	_actualizar_fondo()
	
	# 3) Cargar atril del nuevo jugador
	if atril and atril.has_method("cargar_atril"):
		var datos = GameData.atriles_jugadores[GameData.jugador_actual]
		atril.cargar_atril(datos)

	# 4) Actualizar UI de turno
	actualizar_label_turno()
	set_turno(true)

func _registrar_fin_turno(sin_puntos: bool) -> void:
	if sin_puntos:
		turnos_sin_puntos_consecutivos += 1
	else:
		turnos_sin_puntos_consecutivos = 0

	print("DEBUG turnos_sin_puntos_consecutivos =", turnos_sin_puntos_consecutivos)

	# Si todo el mundo ha pasado 2 veces seguidas → fin de partida
	if turnos_sin_puntos_consecutivos >= GameData.num_jugadores * 2:
		print("🎯 Todos los jugadores han pasado 2 veces seguidas. Fin de partida.")
		es_mi_turno = false

		if turno_timer:
			turno_timer.stop()

		# Guardar puntuaciones finales en GameData
		GameData.puntuaciones_finales = puntuaciones.duplicate()

		get_tree().change_scene_to_packed(END_SCENE)
	else:
		_siguiente_jugador()

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
		var restantes: int = atril.bolsa.quedan()
		print("DEBUG Contador: quedan en bolsa =", restantes)
		label.text = str(restantes)
	else:
		print("DEBUG Contador: atril no tiene bolsa o no tiene método 'quedan'")
		label.text = "0"

func _es_fin_partida() -> bool:
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		return false

	# 1) Si la bolsa aún tiene fichas, seguro que NO es fin de partida
	if atril.bolsa and atril.bolsa.has_method("quedan"):
		if atril.bolsa.quedan() > 0:
			return false
	else:
		# Si no hay info de bolsa, por seguridad no terminamos la partida
		return false

	# 2) Comprobar si el atril del jugador actual está vacío
	if atril.has_method("exportar_atril"):
		var letras: Array = atril.exportar_atril()
		for l in letras:
			if l != null:
				# Todavía tiene alguna letra
				return false

	# Si bolsa vacía Y atril del jugador actual vacío → fin de partida
	return true

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

	# ---------------------------------------
	# 1) ¿Hay fichas colocadas este turno?
	# ---------------------------------------
	var hay_fichas_colocadas := false
	if tablero.has_method("get"):
		var fichas_colocadas = tablero.get("fichas_turno_actual")
		if typeof(fichas_colocadas) == TYPE_ARRAY and not fichas_colocadas.is_empty():
			hay_fichas_colocadas = true

	# CASO A: no hay fichas colocadas → pasar turno
	if not hay_fichas_colocadas:
		print("➡ Finalizar turno sin colocar fichas: se pasa el turno (sin puntos).")
		es_mi_turno = false
		if turno_timer:
			turno_timer.stop()
		_registrar_fin_turno(true)  # turno sin puntos
		return


	# ---------------------------------------
	# CASO B/C: hay fichas colocadas → validar
	# ---------------------------------------
	es_mi_turno = false  # bloqueamos el turno mientras validamos

	# Bloquear botones del atril
	for child in atril.get_children():
		if child is Button:
			child.disabled = true

	# Atenuar el tablero
	tablero.modulate = Color(1, 1, 1, 0.6)
	tablero.set_process_input(false)

	# Validar jugada (true = válida, false = inválida)
	var ok := await _validar_jugada(tablero)

	if ok:
	# ===============================
	# 1️⃣ Calcular puntos del turno
	# ===============================
		var puntos_turno := 0
		if tablero.has_method("calcular_puntuacion_turno"):
			puntos_turno = tablero.calcular_puntuacion_turno()
			sumar_puntos(puntos_turno)
			puntuacion_jugador_actual = puntuaciones[GameData.jugador_actual]
			print("✅ Jugada válida! Sumados %d puntos. Total: %d" % [puntos_turno, puntuacion_jugador_actual])

	# ===============================
	# 2️⃣ Registrar palabras y limpiar
	# ===============================
		if tablero.has_method("registrar_palabras_turno_actual"):
			tablero.registrar_palabras_turno_actual()

		if tablero.has_method("limpiar_fichas_turno"):
			tablero.limpiar_fichas_turno()

	# Marcar fin del primer turno
		if tablero.es_primer_turno:
			tablero.es_primer_turno = false

	# ===============================
	# 3️⃣ Reponer fichas
	# ===============================
		if atril.has_method("reponer_fichas_colocadas"):
			atril.reponer_fichas_colocadas()
		actualizar_contador_bolsa()

	# ===============================
	# 4️⃣ Fin de partida clásico
	# ===============================
		if _es_fin_partida():
			print("🎉 Fin de la partida, cambiando a pantalla de fin.")
			if turno_timer:
				turno_timer.stop()
			get_tree().change_scene_to_packed(END_SCENE)
			return

	# ===============================
	# 5️⃣ Preparar turno
	# ===============================
		if turno_timer:
			turno_timer.stop()
		tablero.modulate = Color(1, 1, 1, 1)
		tablero.set_process_input(true)

	# ===============================
	# 6️⃣ Nuevo sistema:
	#     registrar si hubo puntos
	# ===============================
	# Si puntos_turno > 0 → reset del contador
	# Si puntos_turno == 0 → cuenta como "pasar turno"
		_registrar_fin_turno(puntos_turno <= 0)


	else:
		# ❌ CASO C: jugada inválida
		# _validar_jugada ya habrá devuelto las fichas al atril cuando toca
		print("❌ Jugada inválida. Manteniendo turno del mismo jugador.")

		# Reactivar botones del atril
		for child in atril.get_children():
			if child is Button:
				child.disabled = false

		# Restaurar tablero para que pueda volver a colocar
		tablero.modulate = Color(1, 1, 1, 1)
		tablero.set_process_input(true)

		# Sigue siendo el mismo turno (el timer continúa contando)
		es_mi_turno = true

# NUEVO
func _on_cancelar_colocacion_pressed() -> void:
	if not es_mi_turno:
		print("Cancelar ignorado: no es mi turno.")
		return

	var tablero := get_tree().current_scene.get_node_or_null("Board")
	if tablero == null:
		push_warning("No se encontró el nodo 'Board'")
		return

	# Devuelve las fichas colocadas en este turno al atril
	if tablero.has_method("devolver_fichas_turno"):
		tablero.devolver_fichas_turno()
	else:
		push_warning("El Board no tiene 'devolver_fichas_turno'")

	# Reactiva el turno para seguir colocando
	_reactivar_turno()
	print("🔄 Colocación cancelada: fichas devueltas y turno reactivado.")



# ===========================
# 🔹 Preguntar si la palabra cumple la temática
# ===========================
var esperando_respuesta: bool = false
var respuesta_tematica: bool = false

# Función para preguntar si se acepta la palabra en temáticas
func _preguntar_tematica(palabra: String) -> bool:
	
	#Si solo hay un jugador no hace falta validar
	if GameData.num_jugadores <= 1:
		return true
	
	var panel: Panel = $PanelConfirmarPalabra
	var label: Label = panel.get_node("VBoxContainer/LabelPalabra") as Label
	var boton_si: Button = panel.get_node("VBoxContainer/BotonSi") as Button
	var boton_no: Button = panel.get_node("VBoxContainer/BotonNo") as Button

	# Configurar el panel
	#label.text = "¿Se acepta la palabra \"%s\"?".format(palabra)
	label.text = "¿Se acepta la palabra \"%s\"?" % palabra
	panel.visible = true

	
	
	# Variable para almacenar la respuesta
	var respuesta: bool = false

	# Crear Callables para conectar
	var callable_si = Callable(self, "_on_boton_si_presionado")
	var callable_no = Callable(self, "_on_boton_no_presionado")

	# Guardar temporalmente la respuesta
	_respuesta_tematica = null

	# Conectar botones
	boton_si.pressed.connect(callable_si)
	boton_no.pressed.connect(callable_no)

	# Esperar a que el jugador pulse un botón
	while _respuesta_tematica == null:
		await get_tree().process_frame

	# Guardar la respuesta final
	respuesta = _respuesta_tematica

	# Desconectar botones
	if boton_si.pressed.is_connected(callable_si):
		boton_si.pressed.disconnect(callable_si)
	if boton_no.pressed.is_connected(callable_no):
		boton_no.pressed.disconnect(callable_no)

	# Ocultar panel
	panel.visible = false

	return respuesta


# Funciones que usan los botones
var _respuesta_tematica  = null

func _on_boton_si_presionado():
	_respuesta_tematica = true

func _on_boton_no_presionado():
	_respuesta_tematica = false


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
	
	
	# ---- Validación temática ----
	if GameData.selected_theme != "":
		for palabra in tablero.palabras_turno_actual:
			var aceptada = await _preguntar_tematica(palabra)
			if not aceptada:
				print("Palabra no aceptada por temática:", palabra)
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
	# Si no es mi turno, no hago nada
	if not es_mi_turno:
		return

	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril == null:
		mostrar_error("No se encontró el atril.")
		return

	# --- Mostrar mensaje en pantalla ---
	var mensaje := get_tree().current_scene.get_node_or_null("MensajeIntercambio")
	if mensaje:
		mensaje.text = "Selecciona fichas y pulsa ENTER para intercambiar (ESC para cancelar)"
		mensaje.visible = true

	# Desactivar tablero mientras se eligen fichas
	var tablero := get_tree().current_scene.get_node_or_null("Board")
	if tablero:
		tablero.modulate = Color(1, 1, 1, 0.5)
		tablero.set_process_input(false)

	print("Selecciona las fichas que deseas intercambiar (clic).")

	# Esperamos selección de fichas
	var fichas_a_cambiar = await atril.seleccionar_fichas_para_intercambio()

	# Ocultar mensaje
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

	# Comprobar que hay suficientes fichas en la bolsa ANTES de intercambiar
	if atril.bolsa and atril.bolsa.has_method("quedan") and atril.bolsa.quedan() < 7:
		mostrar_error("No puedes intercambiar: quedan menos de 7 fichas en la bolsa.")
		if tablero:
			tablero.modulate = Color(1, 1, 1, 1)
			tablero.set_process_input(true)
		return

	# Ejecutar el intercambio de verdad
	if atril.has_method("intercambiar_fichas"):
		atril.intercambiar_fichas(fichas_a_cambiar)
	else:
		print("Atril no tiene método 'intercambiar_fichas'.")
		if tablero:
			tablero.modulate = Color(1, 1, 1, 1)
			tablero.set_process_input(true)
		return

	# Reactivar tablero (aunque en nada pasaremos el turno)
	if tablero:
		tablero.modulate = Color(1, 1, 1, 1)
		tablero.set_process_input(false)  # lo dejamos desactivado hasta el siguiente jugador

	# Actualizar contador de bolsa
	actualizar_contador_bolsa()
	print("Fichas intercambiadas correctamente.")

	# 🔹 Este turno termina aquí (intercambiar cuenta como turno)
	es_mi_turno = false

	# 🔹 Dejarte ver tus fichas nuevas un momento
	await get_tree().create_timer(0.9).timeout

	# 🔹 Pasar al siguiente jugador (guardando/cargando atril como siempre)
	_siguiente_jugador()

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
	
# ===========================
# 🔹 Timeout del Timer
# ===========================

func _on_TurnoTimer_timeout() -> void:
	if not es_mi_turno:
		return

	tiempo_restante -= 1
	actualizar_ui_tiempo()

	if tiempo_restante > 0:
		return

	print("⏱ Tiempo agotado para jugador", GameData.jugador_actual + 1)
	turno_timer.stop()  # detenemos el timer

	# Forzar fin de turno por tiempo agotado
	await _forzar_fin_turno_por_tiempo()

func _forzar_fin_turno_por_tiempo() -> void:
	_resetear_interacciones_ui()
	
	es_mi_turno = false  # el turno termina sí o sí

	var tablero := get_tree().current_scene.get_node_or_null("Board")
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")

	if tablero == null or atril == null:
		push_warning("No se encontró Board o PanelContainer al forzar fin de turno por tiempo.")
		_siguiente_jugador()
		return

	# 1) Mirar si hay fichas colocadas este turno
	var hay_fichas_colocadas := false
	if tablero.has_method("get"):
		var fichas_colocadas = tablero.get("fichas_turno_actual")
		if typeof(fichas_colocadas) == TYPE_ARRAY and not fichas_colocadas.is_empty():
			hay_fichas_colocadas = true

	# CASO 1: no hay fichas colocadas -> pasar turno sin más
	if not hay_fichas_colocadas:
		print("⏱ Tiempo agotado sin fichas colocadas → turno pasa sin puntos.")
		_siguiente_jugador()
		return

	# CASO 2/3: hay fichas colocadas → validar jugada
	# Bloquear botones del atril
	for child in atril.get_children():
		if child is Button:
			child.disabled = true

	# Atenuar el tablero
	tablero.modulate = Color(1, 1, 1, 0.6)
	tablero.set_process_input(false)

	# Validar jugada
	var ok := await _validar_jugada(tablero)

	if ok:
		# ✅ Jugada válida: sumar puntos y terminar turno
		if tablero.has_method("calcular_puntuacion_turno"):
			var puntos_turno = tablero.calcular_puntuacion_turno()
			sumar_puntos(puntos_turno)
			puntuacion_jugador_actual = puntuaciones[GameData.jugador_actual]
			print("✅ (Tiempo) Jugada válida! Sumados %d puntos. Total: %d" % [puntos_turno, puntuacion_jugador_actual])

		# Registrar palabras y limpiar turno
		if tablero.has_method("registrar_palabras_turno_actual"):
			tablero.registrar_palabras_turno_actual()

		if tablero.has_method("limpiar_fichas_turno"):
			tablero.limpiar_fichas_turno()

		# Marcar fin del primer turno si era el primero
		if tablero.es_primer_turno:
			tablero.es_primer_turno = false

		# Reponer fichas colocadas
		if atril.has_method("reponer_fichas_colocadas"):
			atril.reponer_fichas_colocadas()
		actualizar_contador_bolsa()

		# (opcional) fin de partida si ya tienes END_SCENE y _es_fin_partida()
		if _es_fin_partida():
			print("🎉 Fin de la partida (por tiempo), cambiando a pantalla de fin.")
			get_tree().change_scene_to_packed(END_SCENE)
			return

		print("➡ (Tiempo) Turno finaliza con jugada válida.")
	else:
		# ❌ Jugada inválida: _validar_jugada ya habrá devuelto las fichas al atril
		print("❌ (Tiempo) Jugada inválida, fichas devueltas al atril y turno terminado.")
		# Por si acaso quieres limpiar algo más:
		if tablero.has_method("limpiar_fichas_turno"):
			tablero.limpiar_fichas_turno()

	# Preparar UI para el siguiente jugador
	for child in atril.get_children():
		if child is Button:
			child.disabled = false

	tablero.modulate = Color(1, 1, 1, 1)
	tablero.set_process_input(true)

	# Pasar al siguiente jugador
	_siguiente_jugador()
	
func _resetear_interacciones_ui() -> void:
	# 1) Cancelar drag de la GUI estándar
	var vp := get_viewport()
	if vp and vp.gui_is_dragging():
		vp.gui_cancel_drag()

	# 2) Parar DragPreviewManager global si existe
	var drag_manager := get_tree().current_scene.find_child("DragPreviewManager", true, false)
	if drag_manager and drag_manager.has_method("stop_preview"):
		drag_manager.stop_preview()

	# 3) Resetear atril (modos, colores, estados de botones)
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril and atril.has_method("cancelar_interacciones"):
		atril.cancelar_interacciones()

	# 4) 🔴 Resetear tablero (modo fantasma / teclado)
	var tablero := get_tree().current_scene.get_node_or_null("Board")
	if tablero and tablero.has_method("cancelar_interacciones"):
		tablero.cancelar_interacciones()


# ===========================
# 🔹 Actualizar Label de tiempo
# ===========================
func actualizar_ui_tiempo() -> void:
	if label_tiempo:
		label_tiempo.text = str(tiempo_restante) + "s"

# función finalizar partida
func _on_finalizar_partida_pressed() -> void:
	print("📢 Finalizando partida manualmente…")

	# Para que no sigan funcionando cosas del turno
	es_mi_turno = false

	if turno_timer:
		turno_timer.stop()

	# Si quieres, guarda puntuaciones finales en GameData
	GameData.puntuaciones_finales = puntuaciones.duplicate()

	# Cambiar a pantalla de fin
	get_tree().change_scene_to_packed(END_SCENE)
