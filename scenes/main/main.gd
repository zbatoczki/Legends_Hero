extends Node

var inventory: Dictionary[String, int] = {}

func _ready() -> void:
	ItemEventBus.item_picked_up.connect(on_item_picked_up)
	print(inventory)


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()

#region INVENTORY

func increment_item(item: String, amount: int, max_amount: int) -> void:
	if not item in inventory:
		inventory[item] = 0
	inventory[item] = min(inventory[item] + amount, max_amount)


func decrement_item(item: String, amount: int) -> void:
	if not item in inventory:
		inventory[item] = 0
	inventory[item] = max(inventory[item] - amount, 0)


func on_item_picked_up(item: ItemResource) -> void:
	increment_item(item.name, item.stacks, item.max_stacks)
	print(inventory)


#endregion
