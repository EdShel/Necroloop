extends Node

signal portrait_damaged(amount: int, is_player: bool)
signal portrait_died(is_player: bool)
signal reset_player()

signal battle_win()
signal battle_defeat(reason: String)
