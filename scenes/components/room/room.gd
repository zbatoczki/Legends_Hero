class_name Room extends Area2D

## Clamps the player's camera to this room's rect while the player is inside.

@onready var shape: CollisionShape2D = $CollisionShape2D


func global_rect() -> Rect2:
	var size: Vector2 = shape.shape.size
	return Rect2(shape.global_position - size / 2.0, size)


func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var rect := global_rect()
	camera.limit_left = int(rect.position.x)
	camera.limit_top = int(rect.position.y)
	camera.limit_right = int(rect.end.x)
	camera.limit_bottom = int(rect.end.y)
