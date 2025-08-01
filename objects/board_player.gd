extends Node2D
class_name BoardPlayer

var board: Board
var loop_index: int = 0
var _next_card_index: int = 0
var _next_turn_is_player = false
var _is_finished: bool = false
var _timer: float = 0
var _last_played_cards: Dictionary[bool, CardsData.CardMetadata] = { false: null, true: null }
var _accumulated_multipliers: Dictionary[bool, int] = { false: 1, true: 1 }
var _next_card_caster_is: String = ""

func _ready() -> void:
	board = get_parent()
	
	Bus.portrait_died.connect(func(is_player: bool) -> void:
		_is_finished = true
		
		if is_player:
			await get_tree().create_timer(2.0).timeout
			Bus.battle_defeat.emit("dead")
		else:
			await get_tree().create_timer(2.0).timeout
			Bus.battle_win.emit()
	)

func _exit_tree() -> void:
	_hide_flame_from_previous_card()

func _process(delta: float) -> void:
	if _is_finished:
		return
		
	_timer -= delta
	if _timer <= 0:
		_process_next_card()
		_timer = _get_card_delay(loop_index)

func _process_next_card() -> void:
	_hide_flame_from_previous_card()
	
	while (loop_index < 50):
		var next_card: Card
		if _next_turn_is_player:
			next_card = board.get_player_table_card(_next_card_index)
		else:
			next_card = board.get_enemy_table_card(_next_card_index)
		
		if not next_card:
			_advance_to_next_slot()
			if _is_finished:
				return
			continue
		
		_play_card(next_card, _next_turn_is_player)
		return
	
	_is_finished = true
	Bus.battle_defeat.emit("too_much_loops")

func _play_card(card: Card, is_player: bool) -> void:
	card.set_shining_enabled(true)
	
	var number_look = {}
	if _next_card_caster_is == "player":
		if not is_player:
			number_look = { "reverse": "player" }
		is_player = true
		_next_card_caster_is = ""
	elif _next_card_caster_is == "enemy":
		if is_player:
			number_look = { "reverse": "enemy" }
		is_player = false
		_next_card_caster_is = ""
		
		
	var multiplier = _accumulated_multipliers[is_player]
	var last_player_card = _last_played_cards[is_player]
	var card_meta = CardsData.get_data(card.id)
	match card_meta.id:
		"attack":
			var damage_amount = card_meta.get_amount() * multiplier
			Bus.portrait_damaged.emit(damage_amount, !is_player)
			_spawn_or_update_number_vfx(card.global_position, "-%dHP", damage_amount, "increment", number_look)
			_advance_to_next_slot()
		"regen":
			var heal_amount = card_meta.get_amount() * multiplier
			Bus.portrait_damaged.emit(-heal_amount, is_player)
			_spawn_or_update_number_vfx(card.global_position, "+%dHP", heal_amount, "increment", number_look)
			_advance_to_next_slot()
		"multi":
			if !last_player_card || last_player_card.id != "attack":
				var new_multi = card_meta.get_amount() * multiplier
				_accumulated_multipliers[is_player] = new_multi
				_spawn_or_update_number_vfx(card.global_position, "%dx", new_multi, "replace", number_look)
			else:
				_spawn_or_update_number_vfx(card.global_position, "-", 1, "replace", number_look)
				
			_advance_to_next_slot()
		"reverse":
			if is_player:
				_next_card_caster_is = "player"
			else:
				_next_card_caster_is = "enemy"
			_spawn_or_update_number_vfx(card.global_position, "Reverse", 1, "replace", number_look)
			_advance_to_next_slot()
		"loop":
			_next_card_index = 0
			_next_turn_is_player = false
			loop_index += 1
			_spawn_or_update_number_vfx(card.global_position, "Loop #%d", loop_index, "replace")
			
	
	if card_meta.id != "multi":
		_accumulated_multipliers[is_player] = 1
	
	_last_played_cards[is_player] = card_meta
	

func _advance_to_next_slot() -> void:
	if not _next_turn_is_player:
		_next_turn_is_player = true
		return
	_next_turn_is_player = false
	_next_card_index += 1
	
	if _next_card_index >= board.get_slots_count():
		_is_finished = true
		Bus.battle_defeat.emit("no_loop")

func _get_card_delay(loop_index: int) -> float:
	if (loop_index <= 0): return 1.2
	if (loop_index == 1): return 0.5
	if (loop_index == 2): return 0.2
	if (loop_index == 3): return 0.05
	# Don't know how i feel about this
	#if (loop_index == 47): return 0.15
	#if (loop_index == 48): return 0.2
	#if (loop_index == 49): return 0.4
	return 0.025

func _hide_flame_from_previous_card() -> void:
	for card in get_tree().get_nodes_in_group("card") as Array[Card]:
		card.set_shining_enabled(false)

func _spawn_or_update_number_vfx(
	number_position: Vector2,
	format: String,
	value: int,
	op: String,
	look: Dictionary = {}
) -> void:
	var numbers = get_tree().get_nodes_in_group("number_vfx") as Array[NumberVFX]
	var number_vfx_index = numbers.find_custom(func(n: NumberVFX):
		return n.global_position == number_position and n.format == format
	)
	var number_vfx: NumberVFX = null
	if number_vfx_index != -1:
		number_vfx = numbers[number_vfx_index]
		if (op == "increment"): number_vfx.value += value
		if (op == "replace"): number_vfx.value = value
	else:
		var number_vfx_scene = preload("res://objects/vfx/number_vfx.tscn")
		number_vfx = number_vfx_scene.instantiate()
		number_vfx.global_position = number_position
		number_vfx.format = format
		number_vfx.value = value
		board.add_child(number_vfx)
	
	number_vfx.set_look(look)
	number_vfx.invalidate_text()
