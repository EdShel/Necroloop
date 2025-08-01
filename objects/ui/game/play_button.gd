extends Node2D
class_name PlayButton

signal clicked()

func _ready() -> void:
	Bus.reset_player.connect(func():
		toggle_state("play")
	)

func _on_button_pressed() -> void:
	clicked.emit()

func toggle_state(state: String) -> void:
	if state == "play":
		%Button.text = "Play cards"
	else:
		%Button.text = "Cancel"
