extends Node2D
class_name Board

func _ready() -> void:
	_init_enemy_table(["regen", "regen"])

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
