extends Node

signal portrait_damaged(amount: int, is_player: bool)
signal portrait_died(is_player: bool)
signal reset_player()

signal battle_begin()
signal battle_win()
signal battle_defeat(reason: String)
signal battle_cancel()

signal card_drag_begin()
signal card_released()
signal card_snapped_to_slot()

signal enemy_slot_clicked()
