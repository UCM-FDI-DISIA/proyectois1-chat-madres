extends TaloLoadable
class_name PartidaLoadable

var nombres_jugadores := []
var puntuaciones := []

# Esto se llama automáticamente antes de serializar
func register_fields():
	register_field("nombres_jugadores", nombres_jugadores)
	register_field("puntuaciones", puntuaciones)

# Esto se llama al cargar el save
func on_loaded(data: Dictionary) -> void:
	nombres_jugadores = data.get("nombres_jugadores", [])
	puntuaciones = data.get("puntuaciones", [])
