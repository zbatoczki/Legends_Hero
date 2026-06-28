extends Node

@export var item_hud: ItemHUD
## What the player starts the run holding. Edit in the inspector.
@export var starting_inventory: Array[InventoryEntry] = []

func _ready() -> void:
	ItemEventBus.item_picked_up.connect(on_item_picked_up)
	Inventory.changed.connect(on_inventory_changed)
	grant_starting_inventory()


# Reset to a known state (the autoload persists across scene reloads) and grant
# the configured starting items. Runs after connecting to Inventory.changed so
# the HUD picks up the starting amounts.
func grant_starting_inventory() -> void:
	Inventory.clear()
	for entry in starting_inventory:
		if entry == null or entry.item == null:
			continue
		Inventory.add(entry.item.name, entry.amount, entry.item.max_stacks)


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()


func on_item_picked_up(item: ItemResource) -> void:
	Inventory.add(item.name, item.stacks, item.max_stacks)


# Keep the HUD in sync whenever a count changes, whether from a pickup or from
# an action consuming ammo.
func on_inventory_changed(item: String, amount: int) -> void:
	item_hud.update_label(item.to_lower(), str(amount))
