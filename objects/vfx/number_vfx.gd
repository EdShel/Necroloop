extends Node2D
class_name NumberVFX

var format: String = "%d"
var value: int = 0

var _death_tween: Tween = null

func _ready() -> void:
	z_index = Card.Z_INDEX_NUMBER_VFX
	
	%Label.visible_ratio = 0
	var tween = create_tween()
	tween.tween_property(%Label, "visible_ratio", 1.0, 0.1)
	await tween.finished
	
	_restart_death_tween()
	

func invalidate_text() -> void:
	%Label.text = "[wave amp=50.0 freq=5.0]" + (format % value)
	_restart_death_tween()

func _restart_death_tween() -> void:
	%Label.modulate = Color.WHITE
	
	if _death_tween:
		_death_tween.kill()
		_death_tween = null
	
	_death_tween = create_tween()
	_death_tween.tween_interval(0.75)
	_death_tween.tween_property(%Label, "modulate", Color(1, 1, 1, 0), 0.2)
	await _death_tween.finished
	queue_free()
