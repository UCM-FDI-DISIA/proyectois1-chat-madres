extends Button

var manager: Node = null
var is_dragging: bool = false
var mouse_down: bool = false
var mouse_down_pos: Vector2 = Vector2.ZERO
const DRAG_THRESHOLD: float = 6.0

@onready var drag_preview_manager: Node = get_tree().get_current_scene().find_child("DragPreviewManager", true, false)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Clic presionado
			if self.icon == null:
				return
			mouse_down = true
			mouse_down_pos = event.global_position
		else:
			# Botón soltado
			if is_dragging:
				is_dragging = false
				if drag_preview_manager:
					drag_preview_manager.stop_preview()

				var board := get_tree().current_scene.get_node_or_null("Board")
				if board and board.has_method("soltar_ficha_en_tablero"):
					var ok: bool = board.soltar_ficha_en_tablero(event.global_position, self.icon, self)

				# Avisar al manager (Atril) para que pare el preview o haga lo que necesite
				if manager and manager.has_method("on_ficha_soltada"):
					manager.on_ficha_soltada(self)
			else:
				# 🔹 Click corto: prioridad correcta: REORDENAR > INTERCAMBIO > NORMAL
				if mouse_down and self.icon:
					var atril := get_tree().current_scene.get_node_or_null("PanelContainer")
					if atril == null:
						mouse_down = false
						return

					# PRIORIDAD 1: reordenar
					if atril.has_method("registrar_click_reordenar") and atril.modo_reordenar:
						atril.registrar_click_reordenar(self)

					# PRIORIDAD 2: intercambio
					elif atril.has_method("registrar_click_intercambio") and atril.modo_intercambio:
						atril.registrar_click_intercambio(self)

					# PRIORIDAD 3: modo normal (selección/colocación)
					else:
						var board2 := get_tree().current_scene.get_node_or_null("Board")
						if board2 and board2.has_method("empezar_seleccion_desde_hueco"):
							# si empezamos selección para colocar, aseguramos detener preview
							if manager and manager.has_method("on_ficha_soltada"):
								manager.on_ficha_soltada(self)
							board2.empezar_seleccion_desde_hueco(self.icon, self)

					mouse_down = false
					is_dragging = false

			mouse_down = false

	elif event is InputEventMouseMotion:
		# Movimiento del ratón -> iniciar arrastre si supera threshold
		if mouse_down and not is_dragging:
			if (event.global_position - mouse_down_pos).length() > DRAG_THRESHOLD:
				is_dragging = true
				# Avisar manager para que active la preview central
				if manager and manager.has_method("on_ficha_arrastrada"):
					manager.on_ficha_arrastrada(self)
				# Si no hay manager, usar preview local si existe
				elif drag_preview_manager and self.icon:
					drag_preview_manager.start_preview(self.icon, self, event.global_position)

		if is_dragging and drag_preview_manager:
			drag_preview_manager.update_preview(event.global_position)
