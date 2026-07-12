## Spawns several enemy-death explosions at random offsets, then frees itself.
class_name BossDeathComponent extends Node2D

signal boss_death_complete

const DEATH_COMPONENT: PackedScene = preload("uid://d383uqewghmuh")  # enemy_death_component.tscn
const EXPLOSION_ANIMATION = preload("uid://dx1gbikdrcbb5")
const DAMAGE_BIG_1 = preload("uid://b0436k6q7jnd7")

@export var explosion_count: int = 8
## Explosions spawn within this distance of the center.
@export var radius: float = 14.0
## Seconds between explosions.
@export var interval: float = 0.15


func _ready() -> void:
	for i in explosion_count:
		var explosion := DEATH_COMPONENT.instantiate() as EnemyExplosion
		explosion.sprite_frames = EXPLOSION_ANIMATION
		var audio: AudioStreamPlayer = explosion.get_node_or_null("AudioStreamPlayer") 
		if audio != null:
			audio.stream = DAMAGE_BIG_1
		explosion.position = Vector2(
			randf_range(-radius, radius),
			randf_range(-radius, radius),
		)
		add_child(explosion)
		await get_tree().create_timer(interval).timeout
	# Let the last explosion finish its 0.5s life before removing the container.
	boss_death_complete.emit()
	await get_tree().create_timer(0.5).timeout
	queue_free()
