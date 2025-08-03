extends Node

func _ready() -> void:
	Bus.open_game.connect(func() -> void:
		var game_scene = preload("res://objects/board.tscn").instantiate()
		_open_screen(game_scene)
	)
	Bus.open_options.connect(func() -> void:
		var game_scene = preload("res://objects/ui/options/options.tscn").instantiate()
		_open_screen(game_scene)
	)
	Bus.open_menu.connect(func() -> void:
		var game_scene = preload("res://objects/ui/menu/main_menu.tscn").instantiate()
		_open_screen(game_scene)
	)
	
	
func _open_screen(node: Node) -> void:
	for child in get_children():
		child.queue_free()
	add_child(node)
