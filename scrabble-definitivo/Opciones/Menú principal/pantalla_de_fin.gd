extends Control

const MENU_SCENE := preload("res://Opciones/Menú principal/Menú principal.tscn")

@onready var label_titulo: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelTitulo
@onready var label_ganador: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelGanador
@onready var label_ranking: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelRanking
@onready var boton_menu: Button = $CenterContainer/PanelContenido/VBoxContainer/BotonMenu

# ❗ Confeti debe llamarse "Confeti" y estar dentro de CenterContainer
@onready var confeti: CPUParticles2D = $CenterContainer/Confeti


func _ready():
	# Título
	label_titulo.text = "FIN DE LA PARTIDA"
	label_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_titulo.add_theme_font_size_override("font_size", 60)

	# Ganador / Empate
	label_ganador.text = ""
	label_ganador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_ganador.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_ganador.add_theme_font_size_override("font_size", 48)

	# Ranking del resto de jugadores
	label_ranking.text = ""
	label_ranking.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_ranking.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_ranking.add_theme_font_size_override("font_size", 32)

	# Botón menú
	boton_menu.text = "Volver al menú principal"
	boton_menu.pressed.connect(_on_boton_menu_pressed)

	# Mostrar ganador y ranking
	_mostrar_ganador()


func _on_boton_menu_pressed():
	get_tree().change_scene_to_packed(MENU_SCENE)



# ======================================
# Mostrar ganador/empate y resto ranking
# ======================================
func _mostrar_ganador():
	var max_puntos = -1
	var ganadores : Array = []

	# Encontrar el/los jugador(es) con más puntos
	for i in range(GameData.puntuaciones_finales.size()):
		var puntos = GameData.puntuaciones_finales[i]
		if puntos > max_puntos:
			max_puntos = puntos
			ganadores = [i]
		elif puntos == max_puntos:
			ganadores.append(i)

	# Construir el texto del ganador o empate
	var texto_ganador : String
	if ganadores.size() == 1:
		var jugador = GameData.player_names[ganadores[0]]
		texto_ganador = "🏆 GANADOR: %s (%d puntos)" % [jugador, max_puntos]
	else:
		var nombres = []
		for j in ganadores:
			nombres.append(GameData.player_names[j] + " (%d puntos)" % GameData.puntuaciones_finales[j])
		texto_ganador = "🤝 EMPATE ENTRE " + ", ".join(nombres)

	# Mostrar ganador/empate
	label_ganador.text = texto_ganador

	# ======================================
	# Ranking del resto con medallas 🥈 y 🥉
	# ======================================
	var resto_jugadores = []
	for i in range(GameData.player_names.size()):
		if i in ganadores:
			continue
		resto_jugadores.append(i)

	# Ordenar por puntuación descendente
	resto_jugadores.sort_custom(Callable(self, "_compare_indices_por_puntos_desc"))

	var ranking = []
	for pos in range(resto_jugadores.size()):
		var i = resto_jugadores[pos]
		var texto = "%s: %d puntos" % [
			GameData.player_names[i],
			GameData.puntuaciones_finales[i]
		]

		if pos == 0:
			texto = "🥈 " + texto
		elif pos == 1:
			texto = "🥉 " + texto

		ranking.append(texto)

	label_ranking.text = "\n".join(ranking)

	# ============================
	# 🎉 Activar confeti SIEMPRE, gane 1 o haya empate
	# ============================
	if confeti:
		confeti.emitting = true



# ======================================
# Función auxiliar para ordenar índices
# ======================================
func _compare_indices_por_puntos_desc(a, b):
	var pa = GameData.puntuaciones_finales[a]
	var pb = GameData.puntuaciones_finales[b]
	return pb - pa
