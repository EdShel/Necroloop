extends Node2D
class_name Hand

@export var container_width: float = 1720
@export var card_width: float = 200
@export var card_height: float = 250
@export var cards_gap: float = 10

func _ready() -> void:
	for x in get_children():
		remove_child(x)
		x.queue_free()
	var card_scene = preload("res://objects/cards/card.tscn")
	for id in ["attack", "attack","attack","attack","attack","attack","attack","attack","attack", "regen", "loop"]:
		var card = card_scene.instantiate()
		card.id = id
		add_child(card)
	arrange_cards()

func arrange_cards() -> void:
	var cards = get_children() as Array[Card]
	var cards_count = cards.size()
	var offsets = _get_cards_x_offsets(cards_count)
	for i in range(cards_count):
		cards[i].position.x = offsets[i]
	_highlight_hovered_card(-1)

func _get_cards_x_offsets(cards_count: int) -> Array[float]:
	if cards_count == 0:
		return []

	var children_width = cards_count * card_width
	var remaining_space = container_width - children_width
	var gap = min(cards_gap, remaining_space / max(1, cards_count - 1))
	
	var result: Array[float] = []
	for i in range(cards_count):
		result.push_back(i * (card_width + gap))
	return result

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var is_dragging_card = get_tree().get_nodes_in_group("card").any(func(x: Card): return x.is_dragged())
		if is_dragging_card:
			return
		
		var mouse_pos = event.position
		var frame = Rect2(global_position.x - card_width / 2, global_position.y - card_height / 2, container_width, card_height)
		var is_within_frame = frame.has_point(mouse_pos)
		if not is_within_frame:
			_highlight_hovered_card(-1)
			return
		
		var cards_count = get_child_count()
		var offsets = _get_cards_x_offsets(cards_count)
		var mouse_relative = mouse_pos - frame.position
		var hovered_card_index = 0
		for i in range(1, offsets.size()):
			if mouse_relative.x >= offsets[i]:
				hovered_card_index = i
			else:
				break
		if abs(offsets[hovered_card_index] - mouse_relative.x) > card_width:
			hovered_card_index = -1
		
		_highlight_hovered_card(hovered_card_index)
			
func _highlight_hovered_card(hovered_card_index: int) -> void:
	var cards = get_children() as Array[Card]
	for i in range(cards.size()):
		var card = cards[i]
		if i == hovered_card_index:
			card.z_index = Card.Z_INDEX_ACTIVE
			card.position.y = -10
			continue
		card.z_index = Card.Z_INDEX_INACTIVE
		card.position.y = 0
	
