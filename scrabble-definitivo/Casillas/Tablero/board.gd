extends Node2D

const TILEMAP_PATH: String = "TileMap"

@onready var tilemap: TileMap = get_node_or_null(TILEMAP_PATH)
var celdas_ocupadas: Dictionary = {}  # Vector2i -> Sprite2D

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

	# desactivar el hueco de origen y limpiar su icono
	origen_boton.disabled = true
	origen_boton.icon = null

	# si hay método para notificar al atril
	var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
	if atril and atril.has_method("vaciar_hueco"):
		atril.vaciar_hueco(origen_boton)

	return true

# ----------------- helpers -----------------

func _buscar_tilemap() -> TileMap:
	# primero intenta hijo directo
	var tm: TileMap = get_node_or_null("TileMap")
	if tm:
		return tm
	# si no, busca recursivamente
	return _find_tilemap_recursive(self)

func _find_tilemap_recursive(n: Node) -> TileMap:
	for child in n.get_children():
		if child is TileMap:
			return child
		var found := _find_tilemap_recursive(child)
		if found:
			return found
	return null
