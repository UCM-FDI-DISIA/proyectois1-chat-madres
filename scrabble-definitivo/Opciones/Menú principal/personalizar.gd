extends Control

@export var METODOS_PUNTUACION := [
	"Clasico",
	"Bonus Palabra Larga",
	"Solo Vocales",
	"Palabra Perfecta",
	"Triple Letra Inicial",
	"Puntaje Progresivo",
	"Letra Duplicada"
]

var DESCRIPCIONES := {
	"Clasico": "Cada letra tiene su valor normal, sin cambios.",
	"Bonus Palabra Larga": "Palabras largas dan puntos extra.",
	"Solo Vocales": "Solo las vocales suman puntos.",
	"Palabra Perfecta": "Palabra completa sin comodines da bonus.",
	"Triple Letra Inicial": "La primera letra de cada palabra triplica su valor.",
	"Puntaje Progresivo": "Cada letra consecutiva aumenta su valor.",
	"Letra Duplicada": "Letras repetidas en la palabra suman doble."
}

var metodo_puntuacion: String = "Clasico"

func _ready():
	# Inicializar SpinBox
	if $TiempoSpinBox:
		$TiempoSpinBox.value = GameData.tiempo_por_turno if "tiempo_por_turno" in GameData else 30
	
	# Conectar botón
	if $ConfirmarBtn:
		$ConfirmarBtn.pressed.connect(_on_confirmar_pressed)
		
	# Llenar OptionButton y conectar señal
	for metodo in METODOS_PUNTUACION:
		$modo_option.add_item(metodo)
	$modo_option.item_selected.connect(_on_modo_option_item_selected)

	# Selección por defecto
	$modo_option.select(0)
	metodo_puntuacion = METODOS_PUNTUACION[0]
	_actualizar_descripcion()


func _on_confirmar_pressed():
	# Guardar tiempo y modo en GameData
	if $TiempoSpinBox:
		GameData.tiempo_por_turno = $TiempoSpinBox.value
	GameData.metodo_puntuacion = metodo_puntuacion
	print("🎯 Modo de juego guardado:", GameData.metodo_puntuacion)
	
	# Cambiar a pantalla de juego
	get_tree().change_scene_to_file("res://Juego/Pantalla de juego.tscn")


func _on_modo_option_item_selected(index: int):
	metodo_puntuacion = METODOS_PUNTUACION[index]
	_actualizar_descripcion()


func _actualizar_descripcion():
	if $DescripcionLabel:
		$DescripcionLabel.text = DESCRIPCIONES.get(metodo_puntuacion, "")
