extends Node2D
class_name Board

@export var encounter_index: int = 0
var _board_player: BoardPlayer = null

func _enter_tree() -> void:
	_begin_encounter(EncountersData.get_data(encounter_index))

func _ready() -> void:
	var initial_cards: Array[String] = ["attack", "attack", "attack"]
	%Hand.add_cards(initial_cards)
	
	Bus.battle_win.connect(func():
		_board_player.queue_free()
		_board_player = null
		
		var completed_encounter = EncountersData.get_data(encounter_index)
		%Hand.add_cards(completed_encounter.reward_cards)
		
		var next_encounter = EncountersData.get_data(encounter_index + 1)
		if not next_encounter:
			var popup = preload("res://objects/ui/popup/my_popup.tscn").instantiate()
			popup.title_text = "Victory"
			popup.message_text = "You have defeated every enemy! You can continue playing though"
			get_tree().root.add_child(popup)
			await popup.closed
			popup.queue_free()
			encounter_index = 0
		else:
			var popup = preload("res://objects/ui/popup/my_popup.tscn").instantiate()
			popup.title_text = "Foe defeated"
			popup.message_text = "Brilliant planning! Wait, who's lurking out there in the shadows?"
			get_tree().root.add_child(popup)
			await popup.closed
			popup.queue_free()
			encounter_index += 1
		
		_begin_encounter(EncountersData.get_data(encounter_index))
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
	Bus.battle_cancel.connect(func():
		_board_player.queue_free()
		_board_player = null
		
		Bus.reset_player.emit()
	)
	
func _begin_encounter(data: EncountersData.EncounterMetadata) -> void:
	%EnemyPortrait.set_enemy_encounter(data)
	_init_enemy_table(data.cards)

func _init_enemy_table(cards_ids: Array[String]) -> void:
	for slot in %EnemyTable.get_children():
		for child in slot.get_children():
			if child is Card:
				child.queue_free()
	
	for i in range(cards_ids.size()):
		var slot = %EnemyTable.get_child(i)
		
		var card_id = cards_ids[i]
		if card_id.length() == 0:
			continue
		var card_scene = preload("res://objects/cards/card.tscn")
		var card = card_scene.instantiate() as Card
		card.id = card_id
		slot.add_child(card)


func _on_play_button_clicked() -> void:
	if _board_player:
		Bus.battle_cancel.emit()
		return
	%PlayButton.toggle_state("pause")
	
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
