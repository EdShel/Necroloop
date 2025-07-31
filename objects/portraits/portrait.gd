extends Sprite2D
class_name Portrait

@export var health: int = 100
@export var id: String = "player"
var _encounter: EncountersData.EncounterMetadata = null

func _ready() -> void:
	_restore_everything()

	Bus.portrait_damaged.connect(func(amount, is_player):
		if is_player != _is_player():
			return
		health = max(0, health - amount)
		_redraw_health()
		if health <= 0:
			Bus.portrait_died.emit(is_player)
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
	
	_redraw_health()
	texture = load("res://sprites/portraits/%s.png" % id)
	
func set_name_label(value: String) -> void:
	%Name.text = value

func _is_player() -> bool:
	return id == "player"

func _redraw_health() -> void:
	%Health.text = "Health %d" % health
