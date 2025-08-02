extends Node2D
class_name Board

@export var encounter_index: int = 0
var _board_player: BoardPlayer = null

func _enter_tree() -> void:
	_begin_encounter(EncountersData.get_data(encounter_index))

func _ready() -> void:
	var initial_cards: Array[String] = ["attack", "attack", "attack"]
	#var initial_cards: Array[String] = ["attack", "attack", "attack", "regen", "multi", "loop", "reverse"]
	%Hand.add_cards(initial_cards)
	
	Bus.battle_win.connect(func():
		_board_player.queue_free()
		_board_player = null
		
		var completed_encounter = EncountersData.get_data(encounter_index)
		var rewards: Array[String] = completed_encounter.reward_cards
		var loop_card_exists = get_tree().get_nodes_in_group("card").any(func(c: Card): return c.id == "loop")
		if loop_card_exists:
			rewards = rewards.filter(func(c: String): return c != "loop")
		%Hand.add_cards(rewards)
		
		var next_encounter = EncountersData.get_data(encounter_index + 1)
		if not next_encounter:
			var popup = preload("res://objects/ui/popup/my_popup.tscn").instantiate()
			popup.title_text = "Victory"
			popup.message_text = "You have defeated every enemy!\nIn the spirit of the game jam's theme 'LOOP', you can keep the cards and restart.\nTry beating enemies in less loops or cards!"
			get_tree().root.add_child(popup)
			await popup.closed
			popup.queue_free()
			encounter_index = 0
		else:
			var popup = preload("res://objects/ui/popup/my_popup.tscn").instantiate()
			popup.title_text = "Foe defeated"
			popup.message_text = "Brilliant planning!\nWait, who else is lurking out there in the shadows?"
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
		
		var encounter = EncountersData.get_data(encounter_index)
		
		var popup = preload("res://objects/ui/popup/my_popup.tscn").instantiate()
		popup.title_text = "This will not work"
		match reason:
			"dead": popup.message_text = "Your health was depleted"
			"too_much_loops": popup.message_text = "This isn't going anywhere - there are too much loops"
			"no_loop": popup.message_text = "You played all your cards but the enemy is still alive.\nDid you forget to place Loop card?"
			_: popup.message_text = "Try again"
		get_tree().root.add_child(popup)
		await popup.closed
		popup.queue_free()
		
		if encounter.enemy_id == "lich":
			_init_enemy_table(encounter.cards)
		
		Bus.reset_player.emit()
	)
	Bus.battle_cancel.connect(func():
		_board_player.queue_free()
		_board_player = null
		
		var encounter = EncountersData.get_data(encounter_index)
		if encounter.enemy_id == "lich":
			_init_enemy_table(encounter.cards)
		
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
	
	var encounter = EncountersData.get_data(encounter_index)
	if encounter.enemy_id == "lich":
		var lich_cards = _generate_lich_cards()
		_init_enemy_table(lich_cards)
	
	_board_player = preload("res://objects/board_player.tscn").instantiate()
	add_child(_board_player)
	Bus.battle_begin.emit()

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

func _generate_lich_cards() -> Array[String]:
	var result: Array[String] = []
	for i in range(get_slots_count()):
		var player_card = get_player_table_card(i)
		if not player_card:
			result.push_back("regen")
			
		elif player_card.id == "attack":
			result.push_back("reverse")
			
		elif player_card.id == "multi":
			result.push_back("reverse")
			
		else:
			result.push_back("regen")
	
	for i in range(get_slots_count() - 1):
		var player_card = get_player_table_card(i)
		if player_card and player_card.id == "reverse":
			result[i] = "multi"
			result[i + 1] = "attack"
			
	
	return result


func _on_hint_button_clicked() -> void:
	if _board_player:
		return
	
	
