extends Node2D

const TILEMAP_PATH: String = "TileMap"

@onready var tilemap: TileMap = get_node_or_null(TILEMAP_PATH)
var celdas_ocupadas: Dictionary = {}  # Vector2i -> Sprite2D

# Fichas colocadas en el turno actual
var fichas_turno_actual: Array = []

# Palabras formadas en el turno actual (ahora guardan letras, no posiciones)
var palabras_turno_actual: Array = []

# Palabras (finales y correctas) jugadas en el tablero
var palabras_jugadas_globales: Array = []

#palabras de la RAE
var palabras_validas: Array = []

func _quitar_tildes(texto: String) -> String:
	var reemplazos = {
		"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
		"Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U"
	}
	for original in reemplazos.keys():
		texto = texto.replace(original, reemplazos[original])
	return texto

func _cargar_diccionario() -> void:
	var ruta := "res://data/diccionario.txt"
	if not FileAccess.file_exists(ruta):
		push_error("❌ No se encontró el archivo de diccionario en " + ruta)
		return

	var file := FileAccess.open(ruta, FileAccess.READ)
	while not file.eof_reached():
		var palabra := file.get_line().strip_edges()
		if palabra != "":
			palabra = _quitar_tildes(palabra)
			palabras_validas.append(palabra.to_upper())
	file.close()

	print("📚 Diccionario cargado con", palabras_validas.size(), "palabras.")


func _ready() -> void:
	_cargar_diccionario()
	if tilemap == null:
		tilemap = _buscar_tilemap()
	if tilemap == null:
		push_error("Board: no se encontró un TileMap hijo. Renómbralo a 'TileMap' o deja uno como hijo directo.")
		return


func soltar_ficha_en_tablero(global_position: Vector2, textura: Texture2D, origen_boton: Button) -> bool:
	if tilemap == null or textura == null:
		return false

	var local_pos: Vector2 = tilemap.to_local(global_position)
	var cell: Vector2i = tilemap.local_to_map(local_pos)

	# comprobar si la celda está dentro de la zona válida del tablero
	var used_rect := tilemap.get_used_rect()
	if not used_rect.has_point(cell):
		return false

	# no colocar si ya hay algo en esa celda
	if celdas_ocupadas.has(cell):
		return false

	# comprobar contigüidad y dirección con fichas del turno
	if not _ficha_valida_para_turno(fichas_turno_actual, cell):
		return false

	# crear sprite en la celda
	var s := Sprite2D.new()
	s.texture = textura
	var cell_px: Vector2 = Vector2(tilemap.tile_set.tile_size)
	var tex_px: Vector2 = textura.get_size()
	if tex_px.x > 0.0 and tex_px.y > 0.0:
		s.scale = cell_px / tex_px
	s.position = tilemap.map_to_local(cell)
	s.z_index = 10
	tilemap.add_child(s)

	# 🔹 Guardar la letra como metadata (para poder reconstruir palabras)
	if origen_boton.has_meta("letra"):
		s.set_meta("letra", origen_boton.get_meta("letra"))
	elif origen_boton.text != "":
		s.set_meta("letra", origen_boton.text)
	else:
		# fallback: intentar deducir la letra del nombre de la textura
		var tex_name := textura.resource_path.get_file().get_basename()
		s.set_meta("letra", tex_name.substr(0, 1).to_upper())

	# guardar la celda como ocupada
	celdas_ocupadas[cell] = s
	fichas_turno_actual.append(cell)

	# 🔹 Guardar referencia al botón de origen (para poder devolverlo después)
	s.set_meta("origen_boton", origen_boton)


	# desactivar el hueco de origen y limpiar su icono
	origen_boton.disabled = true
	origen_boton.icon = null

	# notificar al atril si tiene método
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril and atril.has_method("vaciar_hueco"):
		atril.vaciar_hueco(origen_boton)

	# --- Actualizar palabras del turno ---
	var palabra_nueva := _obtener_palabra_desde_celda(cell)
	if palabra_nueva.size() > 1:
		# evitar duplicados
		var palabra_string := "".join(palabra_nueva)
		var ya_agregada := false
		for palabra in palabras_turno_actual:
			if palabra == palabra_string:
				ya_agregada = true
				break
		if not ya_agregada:
			palabras_turno_actual.append(palabra_string)
			_imprimir_palabras_turno()

	return true


# ----------------- helpers -----------------

func _buscar_tilemap() -> TileMap:
	var tm: TileMap = get_node_or_null("TileMap")
	if tm:
		return tm
	return _find_tilemap_recursive(self)

func _find_tilemap_recursive(n: Node) -> TileMap:
	for child in n.get_children():
		if child is TileMap:
			return child
		var found := _find_tilemap_recursive(child)
		if found:
			return found
	return null


# ===========================
# 🔹 COMPROBACIÓN CONTIGUA (modificada para permitir anclaje por letra del medio)
# ===========================

func _ficha_valida_para_turno(fichas_turno: Array, nueva_celda: Vector2i) -> bool:
	# Si no es el primer turno, asegurarse de que toca alguna ficha ya existente
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

	# Construir la lista prospectiva de celdas del turno: fichas actuales + la nueva
	var placed: Array = []
	for cell in fichas_turno:
		placed.append(cell)
	placed.append(nueva_celda)

	# Si solo hay una celda en el conjunto (colocación única), ya pasó la regla de conexión previa
	if placed.size() == 1:
		return true

	# Determinar si todas las celdas propuestas están en la misma fila o en la misma columna
	var primera: Vector2i = placed[0]
	var all_same_row: bool = true
	var all_same_col: bool = true
	for c in placed:
		if c.y != primera.y:
			all_same_row = false
		if c.x != primera.x:
			all_same_col = false

	# Si no están todas ni en la misma fila ni en la misma columna => forma L u otra forma inválida
	if not all_same_row and not all_same_col:
		return false

	# Validación de contigüidad considerando tanto celdas ocupadas previas como las que se van a colocar.
	# Esto permite "anclar" la palabra en una letra previa (letra del medio) ya existente.
	if all_same_row:
		var y: int = primera.y
		var min_x: int = placed[0].x
		var max_x: int = placed[0].x
		for c in placed:
			if c.y != y:
				return false
			min_x = min(min_x, c.x)
			max_x = max(max_x, c.x)
		# Comprobar que no haya huecos entre min_x..max_x que no estén ocupados ni vayan a colocarse
		for xi in range(min_x, max_x + 1):
			var pos := Vector2i(xi, y)
			if celdas_ocupadas.has(pos):
				continue
			var in_placed: bool = false
			for p in placed:
				if p == pos:
					in_placed = true
					break
			if not in_placed:
				# hueco vacío -> palabra quedaría no contigua
				return false
		return true
	else:
		# misma columna
		var x: int = primera.x
		var min_y: int = placed[0].y
		var max_y: int = placed[0].y
		for c in placed:
			if c.x != x:
				return false
			min_y = min(min_y, c.y)
			max_y = max(max_y, c.y)
		for y2 in range(min_y, max_y + 1):
			var pos2 := Vector2i(x, y2)
			if celdas_ocupadas.has(pos2):
				continue
			var in_placed2: bool = false
			for p2 in placed:
				if p2 == pos2:
					in_placed2 = true
					break
			if not in_placed2:
				return false
		return true


# ===========================
# 🔹 OBTENER PALABRA DESDE CELDA
# ===========================
func _obtener_palabra_desde_celda(celda: Vector2i) -> Array:
	var palabra_total := []

	# Horizontal
	var min_x = celda.x
	var max_x = celda.x
	while celdas_ocupadas.has(Vector2i(min_x - 1, celda.y)):
		min_x -= 1
	while celdas_ocupadas.has(Vector2i(max_x + 1, celda.y)):
		max_x += 1
	if max_x != min_x:
		for x in range(min_x, max_x + 1):
			var pos := Vector2i(x, celda.y)
			if celdas_ocupadas.has(pos):
				palabra_total.append(_obtener_letra_de_celda(pos))

	# Vertical
	var min_y = celda.y
	var max_y = celda.y
	while celdas_ocupadas.has(Vector2i(celda.x, min_y - 1)):
		min_y -= 1
	while celdas_ocupadas.has(Vector2i(celda.x, max_y + 1)):
		max_y += 1
	if max_y != min_y:
		for y in range(min_y, max_y + 1):
			var pos := Vector2i(celda.x, y)
			if celdas_ocupadas.has(pos):
				palabra_total.append(_obtener_letra_de_celda(pos))

	return palabra_total


func _obtener_letra_de_celda(pos: Vector2i) -> String:
	if not celdas_ocupadas.has(pos):
		return ""
	# Castear explícitamente a Sprite2D para que Godot conozca el tipo
	var sprite: Sprite2D = celdas_ocupadas[pos] as Sprite2D
	if sprite == null:
		return ""
	# Si guardaste la letra en metadata, úsala
	if sprite.has_meta("letra"):
		return str(sprite.get_meta("letra"))
	# Si no, intentar deducirla de la textura (nombre del recurso)
	if sprite.texture:
		var name := sprite.texture.resource_path.get_file().get_basename()
		return name.substr(0, 1).to_upper()
	return ""


# ===========================
# 🔹 UTILIDADES TURNOS
# ===========================

func limpiar_fichas_turno() -> void:
	fichas_turno_actual.clear()

func limpiar_palabras_turno() -> void:
	palabras_turno_actual.clear()


# ===========================
# 🔹 LOGGING
# ===========================

func _imprimir_palabras_turno() -> void:
	print("📚 Palabras formadas este turno:")
	for palabra in palabras_turno_actual:
		print("   ➜", palabra)
		

# ===========================
# 🔹 COMPROBAR PALABRAS REPETIDAS
# ===========================

# Comprueba si una palabra ya fue jugada
func es_palabra_repetida(palabra: String) -> bool:
	for jugada in palabras_jugadas_globales:
		if palabra == jugada:
			return true
	return false

# Registra todas las palabras del turno actual en la lista global
func registrar_palabras_turno_actual() -> void:
	for palabra in palabras_turno_actual:
		if not es_palabra_repetida(palabra):
			palabras_jugadas_globales.append(palabra)
			print("✅ Palabra registrada:", palabra)
		else:
			print("⚠️ Palabra repetida, no se registra:", palabra)
			


# --- NUEVO ESTADO ---
var es_primer_turno: bool = true
var snapshot_ocupadas_previas: Array[Vector2i] = []

# Llamar al principio de cada turno para recordar qué casillas estaban ocupadas ANTES de colocar
func empezar_turno() -> void:
	snapshot_ocupadas_previas = []
	for k in celdas_ocupadas.keys():
		snapshot_ocupadas_previas.append(k as Vector2i)


# Devuelve la celda central del TileMap (usando el rectángulo usado)
func _get_celda_centro() -> Vector2i:
	if tilemap == null:
		return Vector2i.ZERO
	var used_rect := tilemap.get_used_rect()
	# centro “matemático”: para dimensiones impares coincide con la estrella
	var cx := used_rect.position.x + used_rect.size.x / 2
	var cy := used_rect.position.y + used_rect.size.y / 2
	return Vector2i(cx, cy)

# ¿Alguna ficha colocada este turno está en la casilla central?
func _toca_centro_en_turno() -> bool:
	var centro := _get_celda_centro()
	for c in fichas_turno_actual:
		if c == centro:
			return true
	return false

# ¿Alguna ficha colocada este turno toca (4-dir) alguna casilla que ya estaba ocupada ANTES de empezar el turno?
func _hay_conexion_con_tablero_previo() -> bool:
	if snapshot_ocupadas_previas.is_empty():
		# Si no había nada previo, estamos en la primera jugada => la regla de conexión no aplica aquí
		return true
	var prev := {}
	for p in snapshot_ocupadas_previas:
		prev[p] = true
	for c in fichas_turno_actual:
		var vecinos := [
			Vector2i(c.x + 1, c.y), Vector2i(c.x - 1, c.y),
			Vector2i(c.x, c.y + 1), Vector2i(c.x, c.y - 1)
		]
		for v in vecinos:
			if prev.has(v):
				return true
	return false
	# Devuelve las fichas del turno al atril y las borra del tablero
	
func devolver_fichas_turno() -> void:
	if fichas_turno_actual.is_empty():
		return

	for cell in fichas_turno_actual:
		if not celdas_ocupadas.has(cell):
			continue
		var sprite: Sprite2D = celdas_ocupadas[cell]
		celdas_ocupadas.erase(cell)

		# Recuperar el botón de origen (el hueco original del atril)
		if sprite.has_meta("origen_boton"):
			var boton: Button = sprite.get_meta("origen_boton")
			if boton:
				boton.disabled = false
				boton.icon = sprite.texture
				boton.text = str(sprite.get_meta("letra")) if sprite.has_meta("letra") else boton.text

		# Eliminar sprite del tablero
		sprite.queue_free()

	fichas_turno_actual.clear()
	
func es_palabra_valida_RAE(palabra: String) -> bool:
	palabra = _quitar_tildes(palabra).to_upper()
	return palabra in palabras_validas
