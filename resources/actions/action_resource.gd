## Base class for an equippable action that can be assigned to action slot A or B
## and triggered from player input. Subclasses define the actual behavior.
class_name ActionResource extends Resource

@export var unlimited_ammo := false
## Minimum seconds between uses of this action. 0 = no cooldown.
@export var cooldown: float = 0.0

## Whether the action can currently run (e.g. the player has enough ammo).
## Callers should check this before playing any wind-up animation so an action
## with no ammo produces no feedback. execute() must also respect it.
func can_execute(_player: Player) -> bool:
	return true


## Perform the action. The player provides world position, facing direction and
## spawning helpers. Implementations are responsible for consuming any required
## ammo from the Inventory.
func execute(_player: Player) -> void:
	pass
