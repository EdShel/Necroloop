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

func _ready() -> void:
	board = get_parent()
	
	Bus.portrait_died.connect(func(is_player: bool) -> void:
		_is_finished = true
		
		if is_player:
			await get_tree().create_timer(0.3).timeot
			Bus.battle_defeat.emit("dead")
		else:
			await get_tree().create_timer(0.3).timeout
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
		var loop_delays = [0.3, 0.2, 0.1, 0.05]
		var delay_index = min(loop_delays.size() - 1, loop_index)
		_timer = loop_delays[delay_index]

func _process_next_card() -> void:
	_hide_flame_from_previous_card()
	
	while (loop_index < 40):
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
	
	var multiplier = _accumulated_multipliers[is_player]
	var last_player_card = _last_played_cards[is_player]
	var card_meta = CardsData.get_data(card.id)
	match card_meta.id:
		"attack":
			Bus.portrait_damaged.emit(card_meta.get_amount() * multiplier, !is_player)
			_advance_to_next_slot()
		"regen":
			Bus.portrait_damaged.emit(-card_meta.get_amount() * multiplier, is_player)
			_advance_to_next_slot()
		"multi":
			if !last_player_card || last_player_card.id != "attack":
				_accumulated_multipliers[is_player] = card_meta.get_amount() * multiplier
			_advance_to_next_slot()
		"loop":
			_next_card_index = 0
			_next_turn_is_player = false
			loop_index += 1
	
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

func _hide_flame_from_previous_card() -> void:
	for card in get_tree().get_nodes_in_group("card") as Array[Card]:
		card.set_shining_enabled(false)
