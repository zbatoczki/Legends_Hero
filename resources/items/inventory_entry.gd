## A single entry of starting inventory: which item to grant and how many.
## Used to configure what the player begins the game holding.
class_name InventoryEntry extends Resource

@export var item: ItemResource
@export var amount: int = 1
