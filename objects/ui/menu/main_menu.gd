extends Node2D


func _on_play_button_area_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Bus.open_game.emit()
			viewport.set_input_as_handled()
			AudioManager.play("paper")


func _on_options_button_area_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Bus.open_options.emit()
			viewport.set_input_as_handled()
			AudioManager.play("paper")


func _on_play_button_area_mouse_entered() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(%PlayText, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(%PlayText, "rotation", deg_to_rad(-8), 0.1)

func _on_play_button_area_mouse_exited() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(%PlayText, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(%PlayText, "rotation", deg_to_rad(0), 0.1)

func _on_options_button_area_mouse_entered() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(%OptionsText, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(%OptionsText, "rotation", deg_to_rad(8), 0.1)

func _on_options_button_area_mouse_exited() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(%OptionsText, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(%OptionsText, "rotation", deg_to_rad(0), 0.1)
	
