extends Node2D
class_name PlayButton

signal clicked()

func _on_button_pressed() -> void:
	clicked.emit()
