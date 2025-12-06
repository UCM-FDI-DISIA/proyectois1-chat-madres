extends Control

const MENU_SCENE := preload("res://Opciones/Menú principal/Menú principal.tscn")

@onready var label_titulo: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelTitulo
@onready var label_ganador: Label = $CenterContainer/PanelContenido/VBoxContainer/LabelGanador
@onready var boton_menu: Button = $CenterContainer/PanelContenido/VBoxContainer/BotonMenu


func _ready():
	label_titulo.text = "FIN DE LA PARTIDA"
	label_ganador.text = ""  # Inicialmente vacío
	boton_menu.text = "Volver al menú principal"

		# 🔹 OPCIONAL: Código de prueba temporal
	# Solo para testear que se muestra el ganador; quitar en producción
	GameData.player_names = ["Tú", "CPU", "Amigo"]
	GameData.puntuaciones_finales = [12, 40, 28]  # CPU gana
	#GameData.puntuaciones_finales = [40, 40, 28]  # Empate

	# Mostrar ganador
	_mostrar_ganador()

	boton_menu.pressed.connect(_on_boton_menu_pressed)
# 

func _on_boton_menu_pressed():
	get_tree().change_scene_to_packed(MENU_SCENE)

# =============================
# 🔹 Función para mostrar ganador
# =============================
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

	# Construir texto del ganador (soporta empates)
	var texto_ganador = ""
	if indices_max.size() == 1:
		texto_ganador = GameData.player_names[indices_max[0]]
	else:
		var nombres = []
		for idx in indices_max:
			nombres.append(GameData.player_names[idx])
		texto_ganador = ", ".join(nombres)

	label_ganador.text = "GANADOR: %s" % texto_ganador
