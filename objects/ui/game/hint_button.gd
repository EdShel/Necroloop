extends Node2D

signal clicked()

func _on_button_pressed() -> void:
	clicked.emit()
