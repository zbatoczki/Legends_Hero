class_name BossDeathComponent extends Node2D

## Spawns several enemy-death explosions at random offsets, then frees itself.

const EXPLOSION: PackedScene = preload("uid://d383uqewghmuh")  # enemy_death_component.tscn

@export var explosion_count: int = 8
## Explosions spawn within this distance of the center.
@export var radius: float = 14.0
## Seconds between explosions.
@export var interval: float = 0.15


func _ready() -> void:
	for i in explosion_count:
		var explosion := EXPLOSION.instantiate()
		explosion.position = Vector2(
			randf_range(-radius, radius),
			randf_range(-radius, radius),
		)
		add_child(explosion)
		await get_tree().create_timer(interval).timeout
	# Let the last explosion finish its 0.5s life before removing the container.
	await get_tree().create_timer(0.5).timeout
	queue_free()
