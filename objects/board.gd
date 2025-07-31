extends Node2D
class_name Board

var _board_player: BoardPlayer = null

func _ready() -> void:
	_init_enemy_table(["regen", "regen"])
	
	Bus.battle_win.connect(func():
		_board_player.queue_free()
		_board_player = null
		
		var popup = preload("res://objects/ui/popup/my_popup.tscn").instantiate()
		popup.title_text = "Foe defeated"
		popup.message_text = "Brilliant planning! Wait, who's lurking out there in the shadows?"
		get_tree().root.add_child(popup)
		await popup.closed
		popup.queue_free()
		
		Bus.reset_player.emit()
	)
	Bus.battle_defeat.connect(func(reason):
		_board_player.queue_free()
		_board_player = null
		
		var popup = preload("res://objects/ui/popup/my_popup.tscn").instantiate()
		popup.title_text = "This will not work"
		match reason:
			"dead": popup.message_text = "Your health was depleted"
			"too_much_loops": popup.message_text = "This isn't going anywhere - there are too much loops"
			"no_loop": popup.message_text = "You played all your cards but the enemy is still alive. Did you forget to place LOOP card?"
			_: popup.message_text = "Try again"
		get_tree().root.add_child(popup)
		await popup.closed
		popup.queue_free()
		
		Bus.reset_player.emit()
	)

func _init_enemy_table(cards_ids: Array[String]) -> void:
	for slot in %EnemyTable.get_children():
		for child in slot.get_children():
			if child is Card:
				child.queue_free()
	
	for i in range(cards_ids.size()):
		var slot = %EnemyTable.get_child(i)
		
		var card_id = cards_ids[i]
		var card_scene = preload("res://objects/cards/card.tscn")
		var card = card_scene.instantiate() as Card
		card.id = card_id
		slot.add_child(card)


func _on_play_button_clicked() -> void:
	if _board_player:
		return
	_board_player = preload("res://objects/board_player.tscn").instantiate()
	add_child(_board_player)

func get_player_table_card(index: int) -> Card:
	var slot = %Table.get_child(index)
	for child in slot.get_children():
		return child
	return null

func get_enemy_table_card(index: int) -> Card:
	var slot = %EnemyTable.get_child(index)
	for child in slot.get_children():
		if child is Card:
			return child
	return null

func get_slots_count() -> int:
	return %Table.get_child_count()
