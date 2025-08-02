extends PanelContainer
class_name MyPopup

signal closed(result: Dictionary)

var _is_closing: bool = false

var title_text: String:
	set(value): %Title.text = value
	get: return %Title.text
var message_text: String:
	set(value): %Message.text = value
	get: return %Message.text

func _ready() -> void:
	modulate = Color.hex(0xffffff00)
	var original_position = %Box.position
	%Box.position = original_position + Vector2(0, 400)
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	tween.tween_property(%Box, "position", original_position, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	

func _on_cancel_button_pressed() -> void:
	_is_closing = true
	closed.emit({})

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		closed.emit({})
		get_viewport().set_input_as_handled()

func _on_close_icon_mouse_entered() -> void:
	if _is_closing or not %CloseIcon:
		return
	var tween = create_tween()
	tween.tween_property(%CloseIcon, "modulate", Color(0.7, 0.7, 0.7, 1.0), 0.2)


func _on_close_icon_mouse_exited() -> void:
	if _is_closing or not %CloseIcon:
		return
	var tween = create_tween()
	tween.tween_property(%CloseIcon, "modulate", Color.WHITE, 0.2)


func _on_close_icon_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_is_closing = true
		closed.emit({})
		get_viewport().set_input_as_handled()
