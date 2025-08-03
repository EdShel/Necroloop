extends VBoxContainer
class_name SpoilerText

@export var texts: Array[String] = []
var _next_index: int = 0

func _ready() -> void:
	%Text.visible = false

func _on_button_pressed() -> void:
	AudioManager.play("paper")
	
	var text = ""
	for i in range(_next_index + 1):
		if i > 0:
			text += ", "
		text += texts[i]
	
	_next_index += 1
	if _next_index >= texts.size():
		%Button.queue_free()
	else:
		text += " (%d more)" % (texts.size() - _next_index)
	
	%Text.visible = true
	%Text.text = text
