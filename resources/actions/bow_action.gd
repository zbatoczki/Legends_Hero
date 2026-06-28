## Fires an arrow projectile in the player's facing direction, consuming one
## arrow from the inventory. Does nothing if the player has no arrows.
class_name BowAction extends ActionResource

const AMMO := "Arrow"

@export var arrow_scene: PackedScene
@export var arrow_speed: float = 120.0

func can_execute(_player: Player) -> bool:
	return unlimited_ammo or Inventory.has(AMMO)


func execute(player: Player) -> void:
	if not can_execute(player):
		return
	Inventory.remove(AMMO, 1)
	player.fire_projectile(arrow_scene, arrow_speed)
