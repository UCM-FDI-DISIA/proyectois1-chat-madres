extends Node2D

const TILEMAP_PATH: String = "TileMap"

@onready var tilemap: TileMap = get_node_or_null(TILEMAP_PATH)
var celdas_ocupadas: Dictionary = {}  # Vector2i -> Sprite2D

# Fichas colocadas en el turno actual
var fichas_turno_actual: Array = []

# Palabras formadas en el turno actual (ahora guardan letras, no posiciones)
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
# 🔹 COMPROBACIÓN CONTIGUA
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

	if fichas_turno.size() == 0:
		return true  # primera ficha del turno siempre permitida

	# Extraer filas y columnas de las fichas colocadas
	var filas := []
	var columnas := []
	for cell in fichas_turno:
		filas.append(cell.y)
		columnas.append(cell.x)

	# Determinar dirección
	var direccion_horizontal: bool = (filas.max() == filas.min())
	var direccion_vertical: bool = (columnas.max() == columnas.min())


	# Si solo hay una ficha colocada, se puede añadir en cualquier sentido (horizontal o vertical)
	if fichas_turno.size() == 1:
		var existing = fichas_turno[0]
		var dx = abs(nueva_celda.x - existing.x)
		var dy = abs(nueva_celda.y - existing.y)
		return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)

	# Secuencia definida: validar contigüidad según dirección, en ambos sentidos
	if direccion_horizontal:
		var min_x = columnas.min()
		var max_x = columnas.max()
		if nueva_celda.y != filas[0]:
			return false
		return nueva_celda.x >= min_x - 1 and nueva_celda.x <= max_x + 1
	elif direccion_vertical:
		var min_y = filas.min()
		var max_y = filas.max()
		if nueva_celda.x != columnas[0]:
			return false
		return nueva_celda.y >= min_y - 1 and nueva_celda.y <= max_y + 1

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
