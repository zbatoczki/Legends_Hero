extends Node2D

@export var projectile: PackedScene
@onready var spawn_point: Marker2D = $SpawnPoint

func launch_projectile(target_direction: Vector2) -> void:
	var projectile_instance = projectile.instantiate()
	projectile_instance.direction = target_direction
	owner.get_parent().add_child(projectile_instance)
	projectile_instance.global_position = spawn_point.global_position
	
func get_spawn_point_position() -> Vector2:
	return spawn_point.global_position
