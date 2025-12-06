extends Control

const MENU_SCENE := preload("res://Opciones/Menú principal/Menú principal.tscn")

@onready var label_titulo: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelTitulo
@onready var label_ganador: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelGanador
@onready var label_ranking: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelRanking
@onready var boton_menu: Button = $CenterContainer/PanelContenido/VBoxContainer/BotonMenu

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
	if GameData.puntuaciones_finales.size() == 0 or GameData.player_names.size() == 0:
		label_ganador.text = "Ganador: N/D"
		return

	# Buscar puntuación máxima
	var max_puntos = -1
	var indices_max = []

	for i in range(GameData.puntuaciones_finales.size()):
		var puntos = GameData.puntuaciones_finales[i]
		if puntos > max_puntos:
			max_puntos = puntos
			indices_max = [i]
		elif puntos == max_puntos:
			indices_max.append(i)

	# Construir texto del ganador o empate
	var texto_ganador = ""
	if indices_max.size() == 1:
		var idx = indices_max[0]
		texto_ganador = "GANADOR: %s (%d puntos)" % [GameData.player_names[idx], GameData.puntuaciones_finales[idx]]
	else:
		var nombres = []
		for idx in indices_max:
			nombres.append("%s (%d puntos)" % [GameData.player_names[idx], GameData.puntuaciones_finales[idx]])
		texto_ganador = "EMPATE ENTRE " + " y ".join(nombres)

	label_ganador.text = texto_ganador

	# ======================================
	# Mostrar el ranking de los demás jugadores
	# ======================================
	var ranking = []
	for i in range(GameData.player_names.size()):
		# saltar los ganadores
		if i in indices_max:
			continue
		ranking.append("%s: %d puntos" % [GameData.player_names[i], GameData.puntuaciones_finales[i]])

	label_ranking.text = "\n".join(ranking)
