extends Node

# Hardcodeamos todas las misiones con recompensa en monedas
var misiones = {
	"PartidasJugadas": {"descripcion":"Juega 10 partidas", "objetivo":1, "progreso":0, "completada":false, "recompensa":10, "entregada":false}, 
	"PuntosTotales": {"descripcion":"Acumula 1000 puntos", "objetivo":1000, "progreso":0, "completada":false, "recompensa":20, "entregada":false},
	"AtrilVacio": {"descripcion":"Vacía tu atril 5 veces", "objetivo":5, "progreso":0, "completada":false, "recompensa":5, "entregada":false},
	"PalabraLarga": {"descripcion":"Juega una palabra de 10 letras o más", "objetivo":1, "progreso":0, "completada":false, "recompensa":5, "entregada":false},
	"ReyDeLasPartidas": {"descripcion":"Juega 50 partidas", "objetivo":50, "progreso":0, "completada":false, "recompensa":50, "entregada":false},
	"ReyDeLosPuntos": {"descripcion":"Acumula 5000 puntos", "objetivo":5000, "progreso":0, "completada":false, "recompensa":50, "entregada":false},
	"Maratonista": {"descripcion":"Juega 100 partidas", "objetivo":100, "progreso":0, "completada":false, "recompensa":100, "entregada":false},
	"PuntuacionMaxima": {"descripcion":"Acumula 20000 puntos", "objetivo":20000, "progreso":0, "completada":false, "recompensa":100, "entregada":false},
	"PalabraPerfecta": {"descripcion":"Forma una palabra que use todas las fichas del atril", "objetivo":1, "progreso":0, "completada":false, "recompensa":20, "entregada":false},
	"AtrilImpecable": {"descripcion":"Vacía tu atril 20 veces", "objetivo":20, "progreso":0, "completada":false, "recompensa":50, "entregada":false},
	"ExpertoLetras": {"descripcion":"Juega 5 palabras de 12 letras o más", "objetivo":5, "progreso":0, "completada":false, "recompensa":20, "entregada":false},
}

func actualizar_misiones(stats):
	for key in misiones.keys():
		var m = misiones[key]
		
		# Actualizar progreso según tipo de misión
		match key:
			"PartidasJugadas", "ReyDeLasPartidas", "Maratonista":
				m["progreso"] = stats["PartidasJugadas"]
			"PuntosTotales", "ReyDeLosPuntos", "PuntuacionMaxima":
				m["progreso"] = stats["PuntosTotales"]
			"AtrilVacio", "AtrilImpecable":
				m["progreso"] = stats["AtrilVacio"]
			"PalabraLarga", "ExpertoLetras":
				m["progreso"] = stats["PalabrasLargas"]
			"PalabraPerfecta":
				m["progreso"] = stats["PalabraPerfecta"]

		# Verificar si se completó la misión
		if not m["completada"] and m["progreso"] >= m["objetivo"]:
			m["completada"] = true
			# Sumar monedas automáticamente
			SaveGame.estadisticas["Monedas"] += m["recompensa"]
			print("¡Misión completada! %s - Recompensa: %d monedas" % [m["descripcion"], m["recompensa"]])

# Mostrar en consola
func mostrar_misiones():
	for key in misiones.keys():
		var m = misiones[key]
		print("%s: %d / %d %s" % [m["descripcion"], m["progreso"], m["objetivo"], "✅" if m["completada"] else "❌"])
