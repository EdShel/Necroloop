extends Sprite2D
class_name Card

const Z_INDEX_DRAG = 4
const Z_INDEX_DRAG_SCRIPTED = 3
const Z_INDEX_ACTIVE = 2
const Z_INDEX_INACTIVE = 1

@export var id: String
@export var belongs_to_enemy: bool = false

var drag_offset: Vector2 = Vector2.INF

func _ready() -> void:
	var data = CardsData.get_data(id)
	%Name.text = data.name
	%Text.text = data.text
	%Graphics.texture = load("res://sprites/card_graphics/%s.png" % data.id)

func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if belongs_to_enemy:
		return
	
	if event is InputEventMouseButton:
		if not (z_index == Z_INDEX_ACTIVE || z_index == Z_INDEX_DRAG || get_parent() is CardSlot):
			return
		var is_dragging_another_card = get_tree().get_nodes_in_group("card").any(func(x: Card): return x != self and x.is_dragged())
		if is_dragging_another_card:
			return
			
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			if drag_offset == Vector2.INF:
				drag_offset = global_position - event.position
				z_index = Z_INDEX_DRAG
			else:
				drag_offset = Vector2.INF
				_release_card()

func _input(event: InputEvent) -> void:
	if belongs_to_enemy:
		return
	
	if event is InputEventMouseMotion:
		if drag_offset == Vector2.INF:
			return
		
		global_position = event.position + drag_offset

func _release_card() -> void:
	var slots = get_tree().get_nodes_in_group("card_slot")
	var nearest_slot_index = 0
	var nearest_slot_distance = global_position.distance_to(slots[nearest_slot_index].global_position)
	for i in range(1, slots.size()):
		var slot = slots[i]
		var distance_to_this_slot = global_position.distance_to(slot.global_position)
		if (distance_to_this_slot < nearest_slot_distance):
			nearest_slot_index = i
			nearest_slot_distance = distance_to_this_slot
	
	var new_parent = slots[nearest_slot_index]
	if nearest_slot_distance > 150:
		new_parent = get_tree().get_first_node_in_group("hand") as Hand
	
	var prev_parent = get_parent()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", new_parent.global_position, 0.1)
	tween.tween_callback(func() -> void:
		z_index = Z_INDEX_INACTIVE
		if prev_parent is Hand:
			prev_parent.arrange_cards()
		elif new_parent is Hand:
			new_parent.arrange_cards()
	)
	
	if new_parent is CardSlot and new_parent.get_child_count() > 0:
		for existing_card in new_parent.get_children():
			existing_card.z_index = Z_INDEX_DRAG_SCRIPTED
			existing_card.reparent(prev_parent, true)
			var swap_tween = get_tree().create_tween()
			swap_tween.tween_property(existing_card, "global_position", prev_parent.global_position, 0.1)
			swap_tween.tween_callback(func() -> void:
				z_index = Z_INDEX_INACTIVE
				if (prev_parent is Hand):
					prev_parent.arrange_cards()
			)
	
	self.reparent(new_parent, true)

func is_dragged() -> bool:
	return drag_offset != Vector2.INF
