extends Node

var _num_players: int = 8
var _bus: String = "SFX"

var _available: Array[AudioStreamPlayer] = [] 
var _queue: Array[String] = []

func _ready():
	Bus.card_snapped_to_slot.connect(func():
		play("spoon")
	)
	Bus.card_drag_begin.connect(func():
		play("paper")
	)
	
	for i in _num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		_available.append(p)
		p.connect("finished", func():
			_available.append(p)
		)
		p.bus = _bus


func play(sound_name: String):
	_queue.append("res://audio/%s.wav" % sound_name)


func _process(delta):
	if not _queue.is_empty() and not _available.is_empty():
		_available[0].stream = load(_queue.pop_front())
		_available[0].play()
		_available.pop_front()
