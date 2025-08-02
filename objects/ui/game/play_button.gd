extends Node2D
class_name PlayButton

signal clicked()

func _ready() -> void:
	Bus.reset_player.connect(func():
		toggle_state("play")
	)

func toggle_state(state: String) -> void:
	if state == "play":
		%Label.text = "Play cards"
	else:
		%Label.text = "Cancel"


func _on_click_area_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit()
			viewport.set_input_as_handled()
			var tween = create_tween()
			tween.tween_property(%Sprite, "position:y", -5, 0.05)
			tween.tween_property(%Sprite, "position:y", 2, 0.02)
			tween.tween_property(%Sprite, "position:y", 0, 0.02)
			


func _on_click_area_mouse_entered() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(%Sprite, "scale:x", 0.9, 0.1)
	tween.tween_property(%Sprite, "rotation", deg_to_rad(2), 0.1)


func _on_click_area_mouse_exited() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(%Sprite, "scale:x", 1.0, 0.1)
	tween.tween_property(%Sprite, "rotation", 0, 0.1)
	
