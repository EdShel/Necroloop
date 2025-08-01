extends Node2D
class_name Portrait

@export var health: int = 100
@export var id: String = "player"
var _encounter: EncountersData.EncounterMetadata = null
var _tween: Tween = null
var _tween_mirror_modifier: float = 1
var _last_call_time: int = 0

func _ready() -> void:
	_restore_everything()
	
	Bus.portrait_damaged.connect(func(amount, is_player):
		if is_player != _is_player():
			return
		health = max(0, health - amount)
		_redraw_health()
		
		if health <= 0:
			_play_hp_dead_animation()
			Bus.portrait_died.emit(is_player)
		else:
			_play_hp_hit_animation("heal" if amount < 0 else "hit")
	)
	
	Bus.reset_player.connect(func():
		_restore_everything()
	)

func set_enemy_encounter(data: EncountersData.EncounterMetadata) -> void:
	id = data.enemy_id
	_encounter = data

func _restore_everything() -> void:
	if id == "player":
		set_name_label("(you)")
		health = 500
	else:
		set_name_label(_encounter.enemy_name)
		health = _encounter.health
		%Background.texture = preload("res://sprites/portraits/enemy_background.png")
		%Frame.texture = preload("res://sprites/portraits/enemy_frame.png")
	
	_redraw_health()
	%Face.texture = load("res://sprites/portraits/%s.png" % id)
	
	if _tween:
		_tween.kill()
		_tween = null
	
	%Health.scale = Vector2(1, 1)
	%Health.rotation = 0
	%Health.modulate = Color.WHITE
	
func set_name_label(value: String) -> void:
	%Name.text = value

func _is_player() -> bool:
	return id == "player"

func _redraw_health() -> void:
	if health >= 999999:
		%Health.text = "Immortal"
		return
	%Health.text = "Health %d" % health

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_R and event.is_pressed():
			_play_hp_hit_animation("hit")
			get_viewport().set_input_as_handled()

func _play_hp_hit_animation(type: String) -> void:
	if _tween:
		_tween.kill()
		_tween = null
	_tween_mirror_modifier = -_tween_mirror_modifier
	
	var now = Time.get_ticks_msec()
	var speed_multiplier: float = 1.0
	var angle_amplitude_rad = deg_to_rad(10)
	var min_scale_factor = max(0.6, %Health.scale.x * 0.8)
	var max_scale_factor = min(2.0, %Health.scale.x * 1.5)
	if now - _last_call_time <= 100:
		speed_multiplier = 0.4
		angle_amplitude_rad = deg_to_rad(2)
		min_scale_factor = 1.95
		max_scale_factor = 2.0
	elif now - _last_call_time <= 200:
		speed_multiplier = 0.4
		angle_amplitude_rad = deg_to_rad(7)
	
	if type == "hit":
		%Health.modulate = Color.hex(0xff5244ff)
	elif type == "heal":
		%Health.modulate = Color.hex(0x8da067ff)
	
	%Health.scale = Vector2(min_scale_factor, min_scale_factor)
	%Health.rotation = angle_amplitude_rad * _tween_mirror_modifier
	_tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	_tween.tween_property(%Health, "scale", Vector2(max_scale_factor, max_scale_factor), 0.2 * speed_multiplier)
	_tween.parallel().tween_property(%Health, "rotation", angle_amplitude_rad * _tween_mirror_modifier, 0.2 * speed_multiplier)
	_tween.parallel().tween_property(%Health, "modulate", Color.WHITE, 0.2 * speed_multiplier)
	_tween.tween_property(%Health, "scale", Vector2(1, 1), 0.4 * speed_multiplier)
	_tween.parallel().tween_property(%Health, "rotation", 0, 0.4 * speed_multiplier)
	
	_last_call_time = now
	
	
func _play_hp_dead_animation() -> void:
	if _tween:
		_tween.kill()
		_tween = null
	%Health.modulate = Color.hex(0xff5244ff)
	%Health.rotation = 0
	
	_tween = create_tween()
	_tween.tween_property(%Health, "scale", Vector2(2.1, 2.1), 0.08)
	_tween.tween_property(%Health, "scale", Vector2(0.9, 0.9), 3.0)
	_tween.parallel().tween_property(%Health, "rotation", deg_to_rad(-5), 3.0)
