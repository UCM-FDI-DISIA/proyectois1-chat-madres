extends Node2D

const TILEMAP_PATH: String = "TileMap"

@onready var tilemap: TileMap = get_node_or_null(TILEMAP_PATH)
var celdas_ocupadas: Dictionary = {}  # Vector2i -> Sprite2D

# Fichas colocadas en el turno actual
var fichas_turno_actual: Array = []

# Palabras formadas en el turno actual (cada palabra = Array de Vector2i)
var palabras_turno_actual: Array = []

func _ready() -> void:
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

	# guardar la celda como ocupada
	celdas_ocupadas[cell] = s
	fichas_turno_actual.append(cell)

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
		var ya_agregada := false
		for palabra in palabras_turno_actual:
			var todos_presentes := true
			for celda_p in palabra_nueva:
				if not palabra.has(celda_p):
					todos_presentes = false
					break
			if todos_presentes:
				ya_agregada = true
				break
		if not ya_agregada:
			palabras_turno_actual.append(palabra_nueva)
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
# 🔹 COMPROBACIÓN PREVENTIVA CONTIGUO HORIZONTAL Y VERTICAL
# ===========================

func _ficha_valida_para_turno(fichas_turno: Array, nueva_celda: Vector2i) -> bool:
	if fichas_turno.size() == 0:
		return true  # primera ficha del turno siempre permitida

	# Extraer filas y columnas de las fichas colocadas
	var filas := []
	var columnas := []
	for cell in fichas_turno:
		filas.append(cell.y)
		columnas.append(cell.x)

	# Determinar dirección
	var direccion_horizontal := false
	var direccion_vertical := false
	if filas.max() == filas.min():
		direccion_horizontal = true
	if columnas.max() == columnas.min():
		direccion_vertical = true

	# Si solo hay 1 ficha: nueva ficha puede estar contigua horizontal o vertical
	if fichas_turno.size() == 1:
		var existing = fichas_turno[0]
		var dx = abs(nueva_celda.x - existing.x)
		var dy = abs(nueva_celda.y - existing.y)
		if (dx == 1 and dy == 0) or (dx == 0 and dy == 1):
			return true
		else:
			return false

	# Secuencia definida: validar contigüidad según dirección
	if direccion_horizontal:
		var min_x = columnas.min()
		var max_x = columnas.max()
		if nueva_celda.y != filas[0]:
			return false
		if nueva_celda.x < min_x - 1 or nueva_celda.x > max_x + 1:
			return false
	elif direccion_vertical:
		var min_y = filas.min()
		var max_y = filas.max()
		if nueva_celda.x != columnas[0]:
			return false
		if nueva_celda.y < min_y - 1 or nueva_celda.y > max_y + 1:
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
			palabra_total.append(Vector2i(x, celda.y))

	# Vertical
	var min_y = celda.y
	var max_y = celda.y
	while celdas_ocupadas.has(Vector2i(celda.x, min_y - 1)):
		min_y -= 1
	while celdas_ocupadas.has(Vector2i(celda.x, max_y + 1)):
		max_y += 1
	if max_y != min_y:
		for y in range(min_y, max_y + 1):
			palabra_total.append(Vector2i(celda.x, y))

	return palabra_total


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
	print("Palabras formadas este turno:")
	for palabra in palabras_turno_actual:
		print(palabra)
