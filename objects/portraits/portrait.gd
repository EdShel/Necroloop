extends Sprite2D
class_name Portrait

@export var health: int = 100
@export var id: String = "player"

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

func _restore_everything() -> void:
	if id == "player":
		set_name_label("(you)")
		health = 500
	elif id == "duck":
		set_name_label("Sapwing")
		health = 300
	
	_redraw_health()
	texture = load("res://sprites/portraits/%s.png" % id)
	
func set_name_label(value: String) -> void:
	%Name.text = value

func _is_player() -> bool:
	return id == "player"

func _redraw_health() -> void:
	%Health.text = "Health %d" % health
