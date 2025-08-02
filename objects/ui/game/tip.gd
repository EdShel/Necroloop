extends Node2D

var _tips_counter: int = 0

func _ready() -> void:
	modulate = Color.hex(0xffffff00)
	
	Bus.battle_begin.connect(func():
		_show_tip("Tip: hold RMB to speed up")
	)
	Bus.battle_win.connect(_hide_tip)
	Bus.battle_defeat.connect(func(_unused): _hide_tip())
	Bus.battle_cancel.connect(_hide_tip)
	
	Bus.card_drag_begin.connect(func():
		_show_tip("Tip: Press RMB to quickly put the card off the table")
	)
	Bus.card_released.connect(_hide_tip)
	
	Bus.enemy_slot_clicked.connect(func():
		_show_tip("This is a slot for enemy's cards - place your cards in the slots below")
		var tip_id = _tips_counter
		await get_tree().create_timer(3).timeout
		if tip_id == _tips_counter:
			_hide_tip()
	)
	

func _show_tip(text: String) -> void:
	_tips_counter += 1
	%Label.text = text
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _hide_tip() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.hex(0xffffff00), 0.1)
