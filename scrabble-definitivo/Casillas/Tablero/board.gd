extends Node2D

const TILEMAP_PATH: String = "TileMap"

@onready var tilemap: TileMap = get_node_or_null(TILEMAP_PATH)
var celdas_ocupadas: Dictionary = {}  # Vector2i -> Sprite2D

# ---------------- puntuaciones por letra ----------------
const LETTER_VALUES := {
	"A": 1, "B": 3, "C": 3, "D": 2, "E": 1, "F": 4, "G": 2, "H": 4,
	"I": 1, "J": 8, "K": 5, "L": 1, "M": 3, "N": 1, "Ñ": 8, "O": 1,
	"P": 3, "Q": 5, "R": 1, "S": 1, "T": 1, "U": 1, "V": 4, "W": 10,
	"X": 8, "Y": 4, "Z": 10
}

# letras posibles para sustituir el comodín "*"
const COMODIN_LETRAS_POSIBLES: Array[String] = [
	"A","B","C","D","E","F","G","H","I","J","K","L","M",
	"N","Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z"
]
# ---------------- selección de letra para comodín ----------------
func _elegir_letra_comodin(s: Sprite2D) -> void:
	# Ventanita para elegir la letra que representará el comodín
	var dialog := AcceptDialog.new()
	dialog.title = "Comodín"
	dialog.dialog_text = "Elige la letra para este comodín:"
	dialog.min_size = Vector2(260, 140)

	var vb := VBoxContainer.new()
	vb.custom_minimum_size = Vector2(240, 90)

	var opciones := OptionButton.new()
	opciones.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	for letra in COMODIN_LETRAS_POSIBLES:
		opciones.add_item(letra)

	opciones.selected = 0

	vb.add_child(opciones)
	dialog.add_child(vb)

	add_child(dialog)
	dialog.popup_centered()

	# Cuando se pulsa Aceptar, guardamos la letra elegida
	dialog.confirmed.connect(
		func() -> void:
			if not is_instance_valid(s):
				dialog.queue_free()
				return
			var idx := opciones.selected
			var letra_elegida: String = COMODIN_LETRAS_POSIBLES[idx]
			s.set_meta("letra", letra_elegida)
			s.set_meta("es_comodin", true)  # lo marcamos para la puntuación
			dialog.queue_free()
	)

	# Si se cierra/cancela, simplemente cerramos el diálogo
	dialog.canceled.connect(
		func() -> void:
			dialog.queue_free()
	)


# ---------------- tipos de casilla ----------------
const TILE_SOURCE_2L := 0
const TILE_SOURCE_2W := 1
const TILE_SOURCE_3L := 2
const TILE_SOURCE_3W := 3
const TILE_SOURCE_ESTRELLA := 4
const TILE_SOURCE_NORMAL := 5
const TILE_SOURCE_FONDO := 6
const TILE_SOURCE_CIAN := 7

# Mapea el source_id del TileSet a un tipo de casilla.
const TILE_TYPE_BY_SOURCE_ID := {
	0: "2L",  # doble letra
	1: "2W",  # doble palabra
	2: "3L",  # triple letra
	3: "3W",  # triple palabra
	4: "2W",  # estrella -> doble palabra
	5: "N",   # normal
	6: "N",   # fondo
	7: "N"    # cian
}

func _get_atril_actual() -> Node:
	# Busca atriles en el grupo "atril_jugador" y devuelve el del jugador actual
	var atriles := get_tree().get_nodes_in_group("atril_jugador")
	for atril in atriles:
		# cada atril tiene @export var indice_jugador
		if atril.indice_jugador == GameData.jugador_actual:
			return atril
	# Fallback por si acaso (modo 1 jugador)
	return get_tree().current_scene.get_node_or_null("PanelContainer")


func _get_multiplicadores_casilla(cell: Vector2i) -> Dictionary:
	# Si la ficha no es nueva, no hay bonus
	if not fichas_turno_actual.has(cell):
		return {
			"mult_letra": 1,
			"mult_palabra": 1,
		}

	if tilemap == null:
		return {
			"mult_letra": 1,
			"mult_palabra": 1,
		}

	var source_id: int = tilemap.get_cell_source_id(0, cell)

	# ID inválido
	if source_id == -1:
		return {
			"mult_letra": 1,
			"mult_palabra": 1,
		}

	var tipo: String = String(TILE_TYPE_BY_SOURCE_ID.get(source_id, "N"))

	var mult_letra: int = 1
	var mult_palabra: int = 1

	match tipo:
		"2L":
			mult_letra = 2
		"3L":
			mult_letra = 3
		"2W":
			mult_palabra = 2
		"3W":
			mult_palabra = 3
		_:
			pass

	return {
		"mult_letra": mult_letra,
		"mult_palabra": mult_palabra,
	}

# ---------------- estado de turno ----------------
var fichas_turno_actual: Array = [] 
var palabras_turno_actual: Array = []
var palabras_jugadas_globales: Array = []

# RAE
var palabras_validas: Array = []

# Selección/cursor
var ficha_tex: Texture2D = null
var ficha_origen: Button = null
var cursor_cell: Vector2i = Vector2i.ZERO
var cursor_visible: bool = false
var modo_teclado_activo: bool = false

# Sprite fantasma que sigue al cursor
var ghost: Sprite2D = null

# Estado conexión
var es_primer_turno: bool = true
var snapshot_ocupadas_previas: Array[Vector2i] = []

# ---------------- util tildes ----------------
func _quitar_tildes(texto: String) -> String:
	var reemplazos := {
		"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
		"Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U"
	}
	for original in reemplazos.keys():
		texto = texto.replace(original, reemplazos[original])
	return texto

# ---------------- diccionario ----------------
func _cargar_diccionario() -> void:
	var ruta := "res://diccionario.txt"
	if not FileAccess.file_exists(ruta):
		push_error("No se encontró el archivo de diccionario en " + ruta)
		return
	var f := FileAccess.open(ruta, FileAccess.READ)
	while not f.eof_reached():
		var p: String = f.get_line().strip_edges()
		if p != "":
			p = _quitar_tildes(p)
			palabras_validas.append(p.to_upper())
	f.close()
	print("Diccionario cargado con ", palabras_validas.size(), " palabras.")

# ---------------- ready ----------------
func _ready() -> void:
	_cargar_diccionario()
	if tilemap == null:
		tilemap = _buscar_tilemap()
	if tilemap == null:
		push_error("Board: no se encontró un TileMap hijo. Renómbralo a 'TileMap'.")
		return

	# ghost inicial
	ghost = Sprite2D.new()
	ghost.visible = false
	ghost.modulate = Color(1,1,1,0.5)
	add_child(ghost)

	# recibir teclado y ratón
	set_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)

	# MUY IMPORTANTE: liberar el foco de la UI para que las teclas lleguen aquí
	_clear_gui_focus()

# ---------------- drag&drop (ya tenías) ----------------
func soltar_ficha_en_tablero(global_position: Vector2, textura: Texture2D, origen_boton: Button) -> bool:
	if tilemap == null or textura == null:
		return false
	var local_pos: Vector2 = tilemap.to_local(global_position)
	var cell: Vector2i = tilemap.local_to_map(local_pos)
	var used_rect := tilemap.get_used_rect()
	if not used_rect.has_point(cell):
		return false
	if celdas_ocupadas.has(cell):
		return false
	if not _ficha_valida_para_turno(fichas_turno_actual, cell):
		return false

	var s := Sprite2D.new()
	s.texture = textura
	var cell_px: Vector2 = Vector2(tilemap.tile_set.tile_size)
	var tex_px: Vector2 = textura.get_size()
	if tex_px.x > 0.0 and tex_px.y > 0.0:
		s.scale = cell_px / tex_px
	s.position = tilemap.map_to_local(cell)
	s.z_index = 10
	tilemap.add_child(s)

	# METADATA de letra para la ficha colocada
	if origen_boton and origen_boton.has_meta("letra"):
		s.set_meta("letra", origen_boton.get_meta("letra"))
	elif origen_boton and origen_boton.text != "":
		s.set_meta("letra", origen_boton.text)
	else:
		var base_name: String = textura.resource_path.get_file().get_basename()
		if base_name == "NULL":
			s.set_meta("letra", "*")  # comodín visual -> "*"
		else:
			s.set_meta("letra", base_name.substr(0, 1).to_upper())
				# Si es comodín ("*"), pedir al jugador qué letra representa
					# Si es comodín ("*"), pedir al jugador qué letra representa
	if s.has_meta("letra") and str(s.get_meta("letra")) == "*":
		_elegir_letra_comodin(s)


	# Registrar ocupación
	celdas_ocupadas[cell] = s
	if not fichas_turno_actual.has(cell):
		fichas_turno_actual.append(cell)

	# Vaciar hueco origen (sin mostrar texto)
	if origen_boton:
		s.set_meta("origen_boton", origen_boton)
		origen_boton.disabled = true
		origen_boton.icon = null
		origen_boton.text = ""  # <- ocultar letra visible
		var atril := _get_atril_actual()
		if atril and atril.has_method("vaciar_hueco"):
			atril.vaciar_hueco(origen_boton)


	_reconstruir_palabras_turno()
	return true

# ---------------- helpers TileMap ----------------
func _buscar_tilemap() -> TileMap:
	var tm: TileMap = get_node_or_null("TileMap")
	if tm:
		return tm
	return _find_tilemap_recursive(self)

func _find_tilemap_recursive(n: Node) -> TileMap:
	for ch in n.get_children():
		if ch is TileMap:
			return ch
		var f := _find_tilemap_recursive(ch)
		if f:
			return f
	return null

# ---------------- contigüidad ----------------
func _ficha_valida_para_turno(fichas_turno: Array, nueva_celda: Vector2i) -> bool:
	if not es_primer_turno and fichas_turno.size() == 0:
		var vecinos := [
			Vector2i(nueva_celda.x + 1, nueva_celda.y),
			Vector2i(nueva_celda.x - 1, nueva_celda.y),
			Vector2i(nueva_celda.x, nueva_celda.y + 1),
			Vector2i(nueva_celda.x, nueva_celda.y - 1)
		]
		var conectado := false
		for v in vecinos:
			if celdas_ocupadas.has(v):
				conectado = true
				break
		if not conectado:
			return false

	var placed: Array = []
	for c in fichas_turno:
		placed.append(c)
	placed.append(nueva_celda)
	if placed.size() == 1:
		return true

	var primera: Vector2i = (placed[0] as Vector2i)
	var same_row := true
	var same_col := true
	for any in placed:
		var c2: Vector2i = (any as Vector2i)
		if c2.y != primera.y:
			same_row = false
		if c2.x != primera.x:
			same_col = false
	if not same_row and not same_col:
		return false

	if same_row:
		var y := primera.y
		var min_x := (placed[0] as Vector2i).x
		var max_x := min_x
		for any2 in placed:
			var c3: Vector2i = (any2 as Vector2i)
			if c3.y != y:
				return false
			min_x = min(min_x, c3.x)
			max_x = max(max_x, c3.x)
		for xi in range(min_x, max_x + 1):
			var pos := Vector2i(xi, y)
			if celdas_ocupadas.has(pos):
				continue
			var in_placed := false
			for anyp in placed:
				if (anyp as Vector2i) == pos:
					in_placed = true
					break
			if not in_placed:
				return false
		return true
	else:
		var x := primera.x
		var min_y := (placed[0] as Vector2i).y
		var max_y := min_y
		for any3 in placed:
			var c4: Vector2i = (any3 as Vector2i)
			if c4.x != x:
				return false
			min_y = min(min_y, c4.y)
			max_y = max(max_y, c4.y)
		for yi in range(min_y, max_y + 1):
			var pos2 := Vector2i(x, yi)
			if celdas_ocupadas.has(pos2):
				continue
			var in_placed2 := false
			for anyp2 in placed:
				if (anyp2 as Vector2i) == pos2:
					in_placed2 = true
					break
			if not in_placed2:
				return false
		return true

# ---------------- letras / palabras ----------------
func _obtener_letra_de_celda(pos: Vector2i) -> String:
	if not celdas_ocupadas.has(pos):
		return ""
	var s: Sprite2D = celdas_ocupadas[pos] as Sprite2D
	if s == null:
		return ""
	if s.has_meta("letra"):
		return str(s.get_meta("letra"))  # puede ser "*"
	if s.texture:
		var base_name: String = s.texture.resource_path.get_file().get_basename()
		if base_name == "NULL":
			return "*"  # comodín visual -> "*"
		return base_name.substr(0,1).to_upper()
	return ""
	
func _es_comodin_en_celda(pos: Vector2i) -> bool:
	if not celdas_ocupadas.has(pos):
		return false
	var s: Sprite2D = celdas_ocupadas[pos] as Sprite2D
	if s == null:
		return false
	return s.has_meta("es_comodin") and bool(s.get_meta("es_comodin"))


func _palabra_horizontal(celda: Vector2i) -> String:
	var min_x := celda.x
	var max_x := celda.x
	while celdas_ocupadas.has(Vector2i(min_x - 1, celda.y)):
		min_x -= 1
	while celdas_ocupadas.has(Vector2i(max_x + 1, celda.y)):
		max_x += 1
	if max_x == min_x:
		return ""
	var letras: Array[String] = []
	for x in range(min_x, max_x + 1):
		letras.append(_obtener_letra_de_celda(Vector2i(x, celda.y)))
	return "".join(letras)

func _palabra_vertical(celda: Vector2i) -> String:
	var min_y := celda.y
	var max_y := celda.y
	while celdas_ocupadas.has(Vector2i(celda.x, min_y - 1)):
		min_y -= 1
	while celdas_ocupadas.has(Vector2i(celda.x, max_y + 1)):
		max_y += 1
	if max_y == min_y:
		return ""
	var letras: Array[String] = []
	for y in range(min_y, max_y + 1):
		letras.append(_obtener_letra_de_celda(Vector2i(celda.x, y)))
	return "".join(letras)

func _reconstruir_palabras_turno() -> void:
	palabras_turno_actual.clear()
	var ya: Dictionary = {}
	for any in fichas_turno_actual:
		var c: Vector2i = (any as Vector2i)
		var ph := _palabra_horizontal(c)
		if ph.length() >= 2 and not ya.has(ph):
			palabras_turno_actual.append(ph)
			ya[ph] = true
		var pv := _palabra_vertical(c)
		if pv.length() >= 2 and not ya.has(pv):
			palabras_turno_actual.append(pv)
			ya[pv] = true

# ---------------- util turnos ----------------
func limpiar_fichas_turno() -> void:
	fichas_turno_actual.clear()

func limpiar_palabras_turno() -> void:
	palabras_turno_actual.clear()

func _imprimir_palabras_turno() -> void:
	for p in palabras_turno_actual:
		print("Palabra turno: ", p)

# ---------------- registro / repetidas ----------------
func es_palabra_repetida(palabra: String) -> bool:
	for j in palabras_jugadas_globales:
		if palabra == j:
			return true
	return false

func registrar_palabras_turno_actual() -> void:
	for p in palabras_turno_actual:
		if not es_palabra_repetida(p):
			palabras_jugadas_globales.append(p)
			print("Palabra registrada:", p)
		else:
			print("Palabra repetida, no se registra:", p)

# ---------------- conexión / centro ----------------
func empezar_turno() -> void:
	# Guardar cómo estaba el tablero al inicio del turno
	snapshot_ocupadas_previas.clear()
	for k in celdas_ocupadas.keys():
		var c: Vector2i = k
		snapshot_ocupadas_previas.append(c)

	# Si al empezar el turno no había nada en el tablero → es el primer turno
	es_primer_turno = snapshot_ocupadas_previas.is_empty()

#se supone que ahora debemos usar esta
#func empezar_turno():
	#fichas_turno_actual.clear()
	#if not es_turno_actual:
		#set_process_input(false)
	#else: set_process_input(true)

func _get_celda_centro() -> Vector2i:
	if tilemap == null:
		return Vector2i.ZERO
	var r := tilemap.get_used_rect()
	return Vector2i(r.position.x + r.size.x / 2, r.position.y + r.size.y / 2)

func _toca_centro_en_turno() -> bool:
	var centro := _get_celda_centro()
	for any in fichas_turno_actual:
		if (any as Vector2i) == centro:
			return true
	return false

func _hay_conexion_con_tablero_previo() -> bool:
	if snapshot_ocupadas_previas.is_empty():
		return true
	var prev: Dictionary = {}
	for p in snapshot_ocupadas_previas:
		prev[p] = true
	for any in fichas_turno_actual:
		var c: Vector2i = (any as Vector2i)
		var v := [
			Vector2i(c.x + 1, c.y),
			Vector2i(c.x - 1, c.y),
			Vector2i(c.x, c.y + 1),
			Vector2i(c.x, c.y - 1)
		]
		for n in v:
			if prev.has(n):
				return true
	return false

func devolver_fichas_turno() -> void:
	if fichas_turno_actual.is_empty():
		return

	for any in fichas_turno_actual:
		var cell: Vector2i = any as Vector2i
		if not celdas_ocupadas.has(cell):
			continue
		var s: Sprite2D = celdas_ocupadas[cell]
		celdas_ocupadas.erase(cell)

		# Restaurar hueco origen: icon SÍ, texto NO; guardar letra en meta
		if s.has_meta("origen_boton"):
			var b: Button = s.get_meta("origen_boton")
			if b:
				b.disabled = false
				b.icon = s.texture
				b.text = ""  # no mostramos la letra en el atril

				var es_comodin := s.has_meta("es_comodin") and bool(s.get_meta("es_comodin"))

				if es_comodin:
					# El comodín vuelve al atril como "*"
					b.set_meta("letra", "*")
				elif s.has_meta("letra"):
					b.set_meta("letra", s.get_meta("letra"))

		s.queue_free()

	fichas_turno_actual.clear()
	palabras_turno_actual.clear()

# ---------------- RAE + comodines ----------------
func es_palabra_valida_RAE(palabra: String) -> bool:
	# Normalizamos (tildes quitadas + mayúsculas)
	var normalizada: String = _quitar_tildes(palabra).to_upper()

	# Sin comodín → comprobación directa
	if normalizada.find("*") == -1:
		return normalizada in palabras_validas

	# Con comodín → probar todas las sustituciones posibles
	return _es_comodin_valido(normalizada)

# Comprueba si una palabra con "*" puede ser alguna palabra válida
func _es_comodin_valido(palabra_con_ast: String) -> bool:
	var indices: Array[int] = []
	for i in range(palabra_con_ast.length()):
		if palabra_con_ast[i] == "*":
			indices.append(i)

	if indices.is_empty():
		return palabra_con_ast in palabras_validas

	return _probar_combinaciones_comodin(palabra_con_ast, indices, 0)

# Backtracking para sustituir "*" por letras posibles
func _probar_combinaciones_comodin(base: String, indices: Array[int], indice_actual: int) -> bool:
	if indice_actual >= indices.size():
		return base in palabras_validas

	var pos: int = indices[indice_actual]
	var antes: String = base.substr(0, pos)
	var despues: String = base.substr(pos + 1)

	for letra in COMODIN_LETRAS_POSIBLES:
		var nueva: String = antes + letra + despues
		if _probar_combinaciones_comodin(nueva, indices, indice_actual + 1):
			return true

	return false

# ---------------- foco UI ----------------
func _clear_gui_focus() -> void:
	var vp := get_viewport()
	if vp and vp.has_method("gui_get_focus_owner"):
		var owner := vp.gui_get_focus_owner()
		if owner:
			owner.release_focus()

# =========================================================
# MODO “clic/teclado” + FANTASMA
# =========================================================
func empezar_seleccion_desde_hueco(tex: Texture2D, origen_boton: Button) -> void:
	# reemplaza cualquier selección previa
	ficha_tex = tex
	ficha_origen = origen_boton
	modo_teclado_activo = false

	# preparar fantasma
	if ghost:
		ghost.texture = tex
		if tilemap and tex:
			var cell_px: Vector2 = Vector2(tilemap.tile_set.tile_size)
			var tex_px: Vector2 = tex.get_size()
			if tex_px.x > 0.0 and tex_px.y > 0.0:
				ghost.scale = cell_px / tex_px
		ghost.modulate = Color(1,1,1,0.5)
		ghost.visible = true

	_actualizar_cursor_a_raton()
	cursor_visible = true
	_clear_gui_focus()
	set_process_input(true)
	queue_redraw()

# seguimiento continuo del ratón mientras no esté el modo teclado armado
func _process(_dt: float) -> void:
	if ficha_tex != null and not modo_teclado_activo:
		_actualizar_cursor_a_raton()
		_actualizar_fantasma()
		if cursor_visible:
			queue_redraw()

# reenviamos unhandled a _input para no perder teclas si hay Controles
func _unhandled_input(e: InputEvent) -> void:
	_input(e)

func _input(event: InputEvent) -> void:
	# --- SIEMPRE: números 1..7 y keypad para seleccionar hueco por teclado ---
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1, KEY_KP_1:
				_select_from_keyboard(1); return
			KEY_2, KEY_KP_2:
				_select_from_keyboard(2); return
			KEY_3, KEY_KP_3:
				_select_from_keyboard(3); return
			KEY_4, KEY_KP_4:
				_select_from_keyboard(4); return
			KEY_5, KEY_KP_5:
				_select_from_keyboard(5); return
			KEY_6, KEY_KP_6:
				_select_from_keyboard(6); return
			KEY_7, KEY_KP_7:
				_select_from_keyboard(7); return
	# ------------------------------------------------------------------------

	if ficha_tex == null:
		return

	# ratón: click izquierdo coloca, derecho cancela
	if event is InputEventMouseButton and event.pressed and not modo_teclado_activo:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_actualizar_cursor_a_raton()
			_intentar_colocar_en_cursor()
			if get_viewport():
				get_viewport().set_input_as_handled()
			return
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_cancelar_seleccion()
			if get_viewport():
				get_viewport().set_input_as_handled()
			return

	# teclado: Enter arma, flechas mueven, Enter/Espacio colocan, ESC cancela
	if event is InputEventKey and event.pressed:
		if get_viewport():
			get_viewport().set_input_as_handled()
		match event.keycode:
			KEY_ESCAPE:
				_cancelar_seleccion()
			KEY_ENTER, KEY_KP_ENTER:
				if not modo_teclado_activo:
					modo_teclado_activo = true
					_clear_gui_focus()
					_actualizar_cursor_a_raton()
					cursor_visible = true
					_actualizar_fantasma()
					queue_redraw()
				else:
					_intentar_colocar_en_cursor()
			KEY_SPACE:
				if modo_teclado_activo:
					_intentar_colocar_en_cursor()
			KEY_LEFT:
				if modo_teclado_activo:
					cursor_cell.x -= 1
					_ajustar_cursor_a_tablero()
					_actualizar_fantasma()
					queue_redraw()
			KEY_RIGHT:
				if modo_teclado_activo:
					cursor_cell.x += 1
					_ajustar_cursor_a_tablero()
					_actualizar_fantasma()
					queue_redraw()
			KEY_UP:
				if modo_teclado_activo:
					cursor_cell.y -= 1
					_ajustar_cursor_a_tablero()
					_actualizar_fantasma()
					queue_redraw()
			KEY_DOWN:
				if modo_teclado_activo:
					cursor_cell.y += 1
					_ajustar_cursor_a_tablero()
					_actualizar_fantasma()
					queue_redraw()

func _draw() -> void:
	# marco opcional
	if not cursor_visible or tilemap == null:
		return
	var used_rect := tilemap.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return
	if not used_rect.has_point(cursor_cell):
		return
	var local_pos := tilemap.map_to_local(cursor_cell)
	var global_pos := tilemap.to_global(local_pos)
	var cell_size := Vector2(tilemap.tile_set.tile_size)
	var top_left := to_local(global_pos) - cell_size * 0.5
	var r := Rect2(top_left, cell_size)
	draw_rect(r, Color(0.6, 0.3, 1.0, 0.18), true)
	draw_rect(r, Color(0.6, 0.3, 1.0, 0.9), false, 2.0, true)

func _intentar_colocar_en_cursor() -> void:
	if ficha_tex == null or tilemap == null:
		return
	var used_rect := tilemap.get_used_rect()
	if not used_rect.has_point(cursor_cell):
		return
	if celdas_ocupadas.has(cursor_cell):
		return
	if not _ficha_valida_para_turno(fichas_turno_actual, cursor_cell):
		return

	var s := Sprite2D.new()
	s.texture = ficha_tex
	var cell_px: Vector2 = Vector2(tilemap.tile_set.tile_size)
	var tex_px: Vector2 = ficha_tex.get_size()
	if tex_px.x > 0.0 and tex_px.y > 0.0:
		s.scale = cell_px / tex_px
	s.position = tilemap.map_to_local(cursor_cell)
	s.z_index = 10
	tilemap.add_child(s)

	# Determinar letra de forma robusta
	if ficha_origen:
		if ficha_origen.has_meta("letra"):
			s.set_meta("letra", ficha_origen.get_meta("letra"))
		elif ficha_origen.text != "":
			s.set_meta("letra", ficha_origen.text)
		elif ficha_tex and ficha_tex.resource_path != "":
			var base_name: String = ficha_tex.resource_path.get_file().get_basename()
			if base_name == "NULL":
				s.set_meta("letra", "*")
			else:
				s.set_meta("letra", base_name.substr(0,1).to_upper())
	else:
		if ficha_tex and ficha_tex.resource_path != "":
			var base_name2: String = ficha_tex.resource_path.get_file().get_basename()
			if base_name2 == "NULL":
				s.set_meta("letra", "*")
			else:
				s.set_meta("letra", base_name2.substr(0,1).to_upper())
					# Si es comodín ("*"), pedir la letra que representa
	if s.has_meta("letra") and str(s.get_meta("letra")) == "*":
		_elegir_letra_comodin(s)


	celdas_ocupadas[cursor_cell] = s
	if not fichas_turno_actual.has(cursor_cell):
		fichas_turno_actual.append(cursor_cell)

	# Vaciar hueco del atril (sin texto visible)
	if ficha_origen:
		s.set_meta("origen_boton", ficha_origen)
		ficha_origen.disabled = true
		ficha_origen.icon = null
		ficha_origen.text = ""  # <- ocultar letra visible
		var atril := _get_atril_actual()
		if atril and atril.has_method("vaciar_hueco"):
			atril.vaciar_hueco(ficha_origen)


	_cancelar_seleccion()
	_reconstruir_palabras_turno()

# --- ratón/celda/ghost ---
func _actualizar_cursor_a_raton() -> void:
	if tilemap == null:
		return
	var mouse_vp := get_viewport().get_mouse_position()
	var local := tilemap.to_local(mouse_vp)
	cursor_cell = tilemap.local_to_map(local)
	_ajustar_cursor_a_tablero()

func _ajustar_cursor_a_tablero() -> void:
	if tilemap == null:
		return
	var r := tilemap.get_used_rect()
	if r.size == Vector2i.ZERO:
		return
	cursor_cell.x = clamp(cursor_cell.x, r.position.x, r.position.x + r.size.x - 1)
	cursor_cell.y = clamp(cursor_cell.y, r.position.y, r.position.y + r.size.y - 1)

func _actualizar_fantasma() -> void:
	if ghost == null or tilemap == null:
		return
	var r := tilemap.get_used_rect()
	if r.has_point(cursor_cell) and ficha_tex != null:
		ghost.visible = true
		ghost.position = tilemap.map_to_local(cursor_cell)
	else:
		ghost.visible = false

func _cancelar_seleccion() -> void:
	ficha_tex = null
	ficha_origen = null
	cursor_visible = false
	modo_teclado_activo = false
	if ghost:
		ghost.visible = false
	queue_redraw()

# --- selección por teclado (y búsqueda robusta de huecos) ---
func _select_from_keyboard(idx: int) -> void:
	var btn := _buscar_hueco_por_orden(idx)
	if btn and not btn.disabled and btn.icon:
		empezar_seleccion_desde_hueco(btn.icon, btn)
		modo_teclado_activo = true
		_clear_gui_focus()
		_actualizar_cursor_a_raton()
		_actualizar_fantasma()
		queue_redraw()
	if get_viewport():
		get_viewport().set_input_as_handled()

func _seleccionar_hueco_por_indice(idx: int) -> void:
	_select_from_keyboard(idx)

func _buscar_hueco_por_orden(idx: int) -> Button:
	# 1) Intentar buscar dentro del ATRIL ACTUAL
	var atril := _get_atril_actual()
	if atril:
		var grid := atril.get_node_or_null("VBoxContainer/Panel/GridContainer")
		if grid and grid is GridContainer:
			var por_nombre := grid.get_node_or_null("Hueco_%d" % idx)
			if por_nombre and por_nombre is Button:
				return por_nombre
			var botones_local: Array[Button] = []
			for c in grid.get_children():
				if c is Button:
					botones_local.append(c)
			if idx >= 1 and idx <= botones_local.size():
				return botones_local[idx - 1]

	# 2) Fallback: búsqueda recursiva en todo el subárbol del atril
	if atril == null:
		return null

	var found := _find_node_recursive(atril, "Hueco_%d" % idx)
	if found and found is Button:
		return found

	var all_buttons: Array[Button] = []
	_collect_buttons_recursive(atril, all_buttons)
	if idx >= 1 and idx <= all_buttons.size():
		return all_buttons[idx - 1]
	return null


func _find_node_recursive(root: Node, name_to_find: String) -> Node:
	if root.name == name_to_find:
		return root
	for ch in root.get_children():
		var r := _find_node_recursive(ch, name_to_find)
		if r:
			return r
	return null

func _collect_buttons_recursive(root: Node, out: Array) -> void:
	for ch in root.get_children():
		if ch is Button:
			out.append(ch)
		_collect_buttons_recursive(ch, out)

# ---------------- PUNTUACIÓN ----------------
func calcular_puntuacion_turno() -> int:
	var total_score: int = 0

	# Sacamos todas las palabras formadas este turno
	var palabras_info: Array = _get_palabras_y_celdas_turno()

	# Actualizamos palabras_turno_actual para que el resto de tu código la use igual que antes
	palabras_turno_actual.clear()

	for info in palabras_info:
		var celdas: Array = info["celdas"]
		var texto: String = info["texto"]

		palabras_turno_actual.append(texto)

		var palabra_score: int = calcular_puntuacion_palabra(celdas)
		total_score += palabra_score
		
# DEBUG: descomenta si quieres ver detalle
		# print("Palabra '%s' = %d puntos" % [texto, palabra_score])

	# DEBUG general
	# print("Puntuación total del turno: %d puntos" % total_score)
	
	return total_score

func calcular_puntuacion_palabra(celdas: Array) -> int:
	var suma_letras: int = 0
	var mult_palabra_total: int = 1

	for any in celdas:
		var cell: Vector2i = any as Vector2i
		var letra: String = _obtener_letra_de_celda(cell)
		if letra == "":
			continue

		var es_comodin := _es_comodin_en_celda(cell)

		var puntos_base: int = 0
		if not es_comodin:
			puntos_base = int(LETTER_VALUES.get(letra, 0))
		# si es comodín, puntos_base se queda en 0

		var mults: Dictionary = _get_multiplicadores_casilla(cell)
		var mult_letra: int = int(mults["mult_letra"])
		var mult_palabra: int = int(mults["mult_palabra"])

		suma_letras += puntos_base * mult_letra
		mult_palabra_total *= mult_palabra

	return suma_letras * mult_palabra_total

func _celdas_palabra_horizontal(celda: Vector2i) -> Array:
	var min_x := celda.x
	var max_x := celda.x
	while celdas_ocupadas.has(Vector2i(min_x - 1, celda.y)):
		min_x -= 1
	while celdas_ocupadas.has(Vector2i(max_x + 1, celda.y)):
		max_x += 1
	if max_x == min_x:
		return []
	var celdas: Array = []
	for x in range(min_x, max_x + 1):
		celdas.append(Vector2i(x, celda.y))
	return celdas

func _celdas_palabra_vertical(celda: Vector2i) -> Array:
	var min_y := celda.y
	var max_y := celda.y
	while celdas_ocupadas.has(Vector2i(celda.x, min_y - 1)):
		min_y -= 1
	while celdas_ocupadas.has(Vector2i(celda.x, max_y + 1)):
		max_y += 1
	if max_y == min_y:
		return []
	var celdas: Array = []
	for y in range(min_y, max_y + 1):
		celdas.append(Vector2i(celda.x, y))
	return celdas

# Devuelve un Array de Diccionarios:
# [ { "celdas": [Vector2i, ...], "texto": "CASA" }, ... ]
func _get_palabras_y_celdas_turno() -> Array:
	var resultado: Array = []
	if fichas_turno_actual.is_empty():
		return resultado

	var ya_vistas: Dictionary = {}

	for any in fichas_turno_actual:
		var c: Vector2i = any as Vector2i

		# ---- palabra horizontal que pasa por c ----
		var min_x := c.x
		var max_x := c.x
		while celdas_ocupadas.has(Vector2i(min_x - 1, c.y)):
			min_x -= 1
		while celdas_ocupadas.has(Vector2i(max_x + 1, c.y)):
			max_x += 1

		if max_x > min_x:
			var clave_h := "H_%d_%d_%d" % [c.y, min_x, max_x]
			if not ya_vistas.has(clave_h):
				ya_vistas[clave_h] = true
				var celdas_h: Array = []
				for x in range(min_x, max_x + 1):
					celdas_h.append(Vector2i(x, c.y))
				var texto_h := _texto_desde_celdas(celdas_h)
				resultado.append({
					"celdas": celdas_h,
					"texto": texto_h,
				})

		# ---- palabra vertical que pasa por c ----
		var min_y := c.y
		var max_y := c.y
		while celdas_ocupadas.has(Vector2i(c.x, min_y - 1)):
			min_y -= 1
		while celdas_ocupadas.has(Vector2i(c.x, max_y + 1)):
			max_y += 1

		if max_y > min_y:
			var clave_v := "V_%d_%d_%d" % [c.x, min_y, max_y]
			if not ya_vistas.has(clave_v):
				ya_vistas[clave_v] = true
				var celdas_v: Array = []
				for y in range(min_y, max_y + 1):
					celdas_v.append(Vector2i(c.x, y))
				var texto_v := _texto_desde_celdas(celdas_v)
				resultado.append({
					"celdas": celdas_v,
					"texto": texto_v,
				})

	return resultado

func _texto_desde_celdas(celdas: Array) -> String:
	var letras: Array[String] = []
	for any in celdas:
		var pos: Vector2i = any as Vector2i
		var letra: String = _obtener_letra_de_celda(pos)
		letras.append(letra)
	return "".join(letras)

# =========================================================
# VALIDAR FIN DE TURNO (centro en el primero, conexión en los demás)
# =========================================================
func validar_fin_de_turno() -> bool:
	# No se ha colocado nada
	if fichas_turno_actual.is_empty():
		print("⚠️ No has puesto ninguna ficha este turno.")
		return false

	# PRIMER TURNO → debe tocar la casilla central
	if es_primer_turno:
		if not _toca_centro_en_turno():
			print("❌ La primera jugada debe pasar por la casilla central.")
			devolver_fichas_turno()
			return false
	else:
		# TURNOS SIGUIENTES → deben tocar el tablero anterior
		if not _hay_conexion_con_tablero_previo():
			print("❌ Las fichas nuevas tienen que tocar una palabra ya existente.")
			devolver_fichas_turno()
			return false

	# Si hemos llegado aquí, la jugada es válida
	registrar_palabras_turno_actual()
	es_primer_turno = false
	print("✅ Jugada válida.")
	return true

func cancelar_interacciones() -> void:
	# Cancelar cualquier selección activa (modo fantasma, teclado, etc.)
	_cancelar_seleccion()
