class_name BoomerangAction extends ActionResource


@export var boomerang_scene: PackedScene

func can_execute(_player: Player) -> bool:
	return not _player.boomerang_thrown


func execute(player: Player) -> void:
	if not can_execute(player):
		return
	player.place_object(boomerang_scene)
