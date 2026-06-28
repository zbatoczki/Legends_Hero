## A signal bus related to player input actions
extends Node

signal inventory_toggled
signal action_a_triggered
signal action_b_triggered


func emit_inventory_toggled() -> void:
	print("inventory toggled")
	inventory_toggled.emit()


func emit_action_a_triggered() -> void:
	action_a_triggered.emit()


func emit_action_b_triggered() -> void:
	action_b_triggered.emit()
