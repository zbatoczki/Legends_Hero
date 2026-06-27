## An signal bus related to items
extends Node

signal item_picked_up(item: ItemResource)
signal dungeon_item_picked_up(item: ItemResource)
signal health_item_picked_up(item: ItemResource)
signal magic_item_picked_up(item: ItemResource)


func emit_item_picked_up(item: ItemResource) -> void:
	item_picked_up.emit(item)


func emit_dungeon_item_picked_up(item: ItemResource) -> void:
	dungeon_item_picked_up.emit(item)


func emit_health_item_picked_up(item: ItemResource) -> void:
	health_item_picked_up.emit(item)


func emit_magic_item_picked_up(item: ItemResource) -> void:
	magic_item_picked_up.emit(item)
