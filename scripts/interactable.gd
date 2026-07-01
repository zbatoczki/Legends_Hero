class_name Interactable extends CollisionObject2D


func can_interact() -> bool:
	return false


func interact(_player: Player) -> void:
	pass


func on_triggered() -> void:
	pass
