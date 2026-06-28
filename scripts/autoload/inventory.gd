## Global player inventory state. Single source of truth queried by the HUD,
## the action system, and (eventually) the inventory screen.
extends Node

signal changed(item: String, amount: int)

var items: Dictionary[String, int] = {}


func add(item: String, amount: int, max_amount: int) -> void:
	items[item] = min(count(item) + amount, max_amount)
	changed.emit(item, items[item])


func remove(item: String, amount: int) -> void:
	items[item] = max(count(item) - amount, 0)
	changed.emit(item, items[item])


func count(item: String) -> int:
	return items.get(item, 0)


func has(item: String, amount: int = 1) -> bool:
	return count(item) >= amount


## Resets every count to zero, notifying listeners so dependent UI clears. The
## autoload survives scene reloads, so this is used to re-establish a known
## starting state when a new run begins.
func clear() -> void:
	var existing: Array[String] = items.keys()
	items.clear()
	for item in existing:
		changed.emit(item, 0)
