extends Node

var _num_players: int = 8
var _bus: String = "SFX"

var _available: Array[AudioStreamPlayer] = [] 
var _queue: Array[Dictionary] = []

func _ready() -> void:
	Bus.card_snapped_to_slot.connect(func():
		play("spoon")
	)
	Bus.card_drag_begin.connect(func():
		play("phit")
	)
	
	for i in _num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		_available.append(p)
		p.connect("finished", func():
			_available.append(p)
		)
		p.bus = _bus


func play(sound_name: String) -> void:
	_queue.append({
		"sound": sound_name,
		"ts": Time.get_ticks_msec(),
	})


func _process(delta: float) -> void:
	var already_played = []
	while not _queue.is_empty() and not _available.is_empty():
		var item = _queue.pop_front()
		var sound_res = "res://audio/%s.wav" % item["sound"]
		if Time.get_ticks_msec() - item["ts"] > 250 or already_played.has(item["sound"]):
			return
		already_played.push_back(item["sound"])
		_available[0].stream = load(sound_res)
		_available[0].play()
		_available.pop_front()
