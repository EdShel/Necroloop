extends Node2D


func _on_area_2d_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			viewport.set_input_as_handled()
			Bus.enemy_slot_clicked.emit()
			
