extends Sprite2D
class_name Card

const Z_INDEX_NUMBER_VFX = 5
const Z_INDEX_DRAG = 4
const Z_INDEX_DRAG_SCRIPTED = 3
const Z_INDEX_ACTIVE = 2
const Z_INDEX_INACTIVE = 1

@export var id: String
@export var belongs_to_enemy: bool = false

var drag_offset: Vector2 = Vector2.INF
var _flame: Node2D = null
var _locked: bool = false
var _tween: Tween = null

var _displacement: float = 0
var _oscillator_velocity: float = 0
var _last_position: Vector2 = Vector2.INF

func _ready() -> void:
	var data = CardsData.get_data(id)
	%Name.text = data.name
	%Text.text = data.text
	%Graphics.texture = load("res://sprites/card_graphics/%s.png" % data.id)
	if data.id == "loop":
		%Frame.texture = preload("res://sprites/loop_frame.png")
	Bus.battle_begin.connect(func():
		_locked = true
		if is_dragged():
			drag_offset = Vector2.INF
			_release_card(true)
	)
	Bus.battle_cancel.connect(func(): _locked = false)
	Bus.battle_win.connect(func(): _locked = false)
	Bus.battle_defeat.connect(func(_reason): _locked = false)

func _process(delta: float) -> void:
	if not is_dragged() and z_index != Z_INDEX_DRAG_SCRIPTED:
		return
	
	if _last_position != Vector2.INF:
		var velocity = (global_position - _last_position) / delta
		_oscillator_velocity += velocity.normalized().x * 0.5
		
		var spring = 200.0
		if z_index == Z_INDEX_DRAG_SCRIPTED:
			spring = 250
		const damp = 10.0
		var force = -spring * _displacement - damp * _oscillator_velocity
		_oscillator_velocity += force * delta
		_displacement += _oscillator_velocity * delta
		
		rotation = _displacement
		
		
	_last_position = global_position
	

func _on_area_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_interaction_disabled():
		return
	
	if event is InputEventMouseButton:
		if not (z_index == Z_INDEX_ACTIVE || z_index == Z_INDEX_DRAG || get_parent() is CardSlot):
			return
		var is_dragging_another_card = get_tree().get_nodes_in_group("card").any(func(x: Card): return x != self and x.is_dragged())
		if is_dragging_another_card:
			return
			
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			viewport.set_input_as_handled()
			if !is_dragged():
				drag_offset = global_position - event.position
				z_index = Z_INDEX_DRAG
				material.set("shader_parameter/x_rot", deg_to_rad(10))
			else:
				drag_offset = Vector2.INF
				_release_card(false)
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			if is_dragged():
				viewport.set_input_as_handled()
				drag_offset = Vector2.INF
				_release_card(true)


func _input(event: InputEvent) -> void:
	if _is_interaction_disabled():
		return
	
	if event is InputEventMouseMotion:
		if drag_offset == Vector2.INF:
			return
		
		global_position = event.position + drag_offset

func _release_card(to_the_hand_only: bool) -> void:
	var prev_parent = get_parent()
	var tween = _create_new_animation_tween()
	
	var new_parent = _find_slot_to_place_card_into()
	var preferred_index_in_parent = -1
	if not new_parent or to_the_hand_only:
		new_parent = get_tree().get_first_node_in_group("hand") as Hand
		var hand_location = new_parent.find_global_position_and_index_for_card(self)
		tween.tween_property(self, "global_position", hand_location["position"], 0.1)
		preferred_index_in_parent = hand_location["index"]
	else:
		tween.tween_property(self, "global_position", new_parent.global_position, 0.1)
		
	tween.parallel().tween_property(self, "rotation", 0, 0.1)
	tween.parallel().tween_property(self, "material:shader_parameter/x_rot", 0, 0.1)
	tween.tween_callback(func() -> void:
		z_index = Z_INDEX_INACTIVE
	)
	
	var existing_card_to_move_into_hand: Card = null
	if new_parent is CardSlot and new_parent.get_child_count() > 0 and new_parent != prev_parent:
		var existing_card: Card = new_parent.get_child(0)
		if prev_parent is CardSlot:
			existing_card.reparent(prev_parent, true)
			existing_card.z_index = Z_INDEX_DRAG_SCRIPTED
			var swap_tween = existing_card._create_new_animation_tween()
			var halfway_point = (prev_parent.global_position + existing_card.global_position) / 2
			swap_tween.tween_property(existing_card, "global_position", halfway_point + Vector2(0, 30), 0.15)
			swap_tween.tween_property(existing_card, "global_position", prev_parent.global_position, 0.15)
			swap_tween.tween_callback(func() -> void:
				existing_card.z_index = Z_INDEX_INACTIVE
			)
			swap_tween.tween_property(existing_card, "rotation", 0, 0.1)
		else:
			existing_card_to_move_into_hand = existing_card
	
	self.reparent(new_parent, true)
	if preferred_index_in_parent != -1:
		new_parent.move_child(self, preferred_index_in_parent)
	
	if existing_card_to_move_into_hand:
		existing_card_to_move_into_hand.z_index = Z_INDEX_DRAG_SCRIPTED
		existing_card_to_move_into_hand._release_card(true)
	elif prev_parent is Hand:
		prev_parent.arrange_cards()
	elif new_parent is Hand:
		new_parent.arrange_cards()

func _find_slot_to_place_card_into() -> CardSlot:
	var slots = get_tree().get_nodes_in_group("card_slot")
	var nearest_slot_index = 0
	var nearest_slot_distance = global_position.distance_to(slots[nearest_slot_index].global_position)
	for i in range(1, slots.size()):
		var slot = slots[i]
		var distance_to_this_slot = global_position.distance_to(slot.global_position)
		if (distance_to_this_slot < nearest_slot_distance):
			nearest_slot_index = i
			nearest_slot_distance = distance_to_this_slot
	
	if nearest_slot_distance > 150:
		return null
	var nearest_slot = slots[nearest_slot_index]
	return nearest_slot

func _create_new_animation_tween() -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	return _tween

func is_dragged() -> bool:
	return drag_offset != Vector2.INF

func set_shining_enabled(value: bool) -> void:
	if value and _flame:
		return
	if not value and not _flame:
		return
	
	if value:
		_flame = preload("res://objects/cards/flame.tscn").instantiate()
		add_child(_flame)
	else:
		_flame.queue_free()
		_flame = null

func get_is_shining_enabled() -> bool:
	return !!_flame;

func _is_interaction_disabled() -> bool:
	return belongs_to_enemy or _locked

func play_hightlighted_animation() -> void:
	z_index = Card.Z_INDEX_ACTIVE
	rotation = 0
	var tween = _create_new_animation_tween().set_parallel(true)
	tween.tween_property(self, "position:y", -30, 0.1)
	tween.tween_property(self, "material:shader_parameter/x_rot", deg_to_rad(6), 0.1)

func play_unhighlight_animation() -> void:
	if z_index != Card.Z_INDEX_ACTIVE:
		return
	
	z_index = Card.Z_INDEX_INACTIVE
	rotation = 0
	var tween = _create_new_animation_tween()
	tween.tween_property(self, "position:y", 0, 0.05)
	tween.tween_property(self, "material:shader_parameter/x_rot", 0, 0.1)
	

func play_shift_to_new_position_in_hand(new_position_x: float) -> void:
	if new_position_x == position.x:
		return
	var tween = create_tween()
	tween.tween_property(self, "position:x", new_position_x, 0.1)
	
