## Places a bomb at the player's position which detonates after its fuse. Consumes
## one bomb from the inventory. Does nothing if the player has no bombs.
class_name BombAction extends ActionResource

const AMMO := "Bomb"

@export var bomb_scene: PackedScene

func can_execute(_player: Player) -> bool:
	return unlimited_ammo or Inventory.has(AMMO)


func execute(player: Player) -> void:
	if not can_execute(player):
		return
	Inventory.remove(AMMO, 1)
	player.place_object(bomb_scene)
