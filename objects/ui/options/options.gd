extends Node2D

var _music_bus_index: int
var _sfx_bus_index: int

var _music_volume: float
var _sfx_volume: float

func _ready() -> void:
	_music_bus_index = AudioServer.get_bus_index("Music")
	_sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	_music_volume = db_to_linear(AudioServer.get_bus_volume_db(_music_bus_index)) * 100
	_update_music_label()
	_sfx_volume = db_to_linear(AudioServer.get_bus_volume_db(_sfx_bus_index)) * 100
	_update_music_label()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		Bus.open_menu.emit()


func _on_music_minus_pressed() -> void:
	_update_music(_music_volume - 5)

func _on_music_plus_pressed() -> void:
	_update_music(_music_volume + 5)

func _update_music(new_value: float) -> void:
	_music_volume = clamp(new_value, 0, 100)
	AudioServer.set_bus_volume_db(_music_bus_index, linear_to_db(_music_volume / 100.0))
	AudioServer.set_bus_mute(_music_bus_index, _music_volume < 1)
	_update_music_label()
	AudioManager.play("paper")

func _update_music_label() -> void:
	%MusicValue.text = "%d%%" % _music_volume


func _on_sfx_minus_pressed() -> void:
	_update_sfx(_sfx_volume - 5)


func _on_sfx_plus_pressed() -> void:
	_update_sfx(_sfx_volume + 5)

func _update_sfx(new_value: float) -> void:
	_sfx_volume = clamp(new_value, 0, 100)
	AudioServer.set_bus_volume_db(_sfx_bus_index, linear_to_db(_sfx_volume / 100.0))
	AudioServer.set_bus_mute(_sfx_bus_index, _sfx_volume < 1)
	_update_sfx_label()
	AudioManager.play("paper")

func _update_sfx_label() -> void:
	%SFXValue.text = "%d%%" % _sfx_volume


func _on_save_button_pressed() -> void:
	Bus.open_menu.emit()
