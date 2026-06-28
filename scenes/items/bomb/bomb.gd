## A placed bomb that detonates after its fuse, damaging enemies within blast
## range. Spawned by BombAction at the player's position.
class_name Bomb extends Node2D

@export var fuse_time: float = 2.0
@export var damage: int = 2
@export var knockback_force: float = 200.0

## How many seconds before detonation the bomb starts flashing.
@export var flash_lead_time: float = 1.0

## Seconds between flash toggles at the start of the warning (slowest).
@export var flash_interval_start: float = 0.2

## Seconds between flash toggles just before detonation (fastest).
@export var flash_interval_end: float = 0.04

# Accumulated flash cycles; each whole unit is one on/off toggle.
var _flash_phase := 0.0

@onready var fuse: Timer = $Fuse
@onready var blast_area: Area2D = $BlastArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound

func _ready() -> void:
	fuse.start(fuse_time)


func _process(delta: float) -> void:
	var remaining := fuse.time_left
	if remaining <= 0.0 or remaining > flash_lead_time:
		return
	# Blink faster as the fuse runs out: shrink the toggle interval from start to
	# end across the warning window, accumulating phase so the rate can vary.
	var warning_progress := 1.0 - remaining / flash_lead_time
	var interval := lerpf(flash_interval_start, flash_interval_end, warning_progress)
	_flash_phase += delta / interval
	var flash_on := int(_flash_phase) % 2 == 0
	animated_sprite_2d.material.set_shader_parameter("amount", 1.0 if flash_on else 0.0)


func _on_fuse_timeout() -> void:
	explode()


func explode() -> void:
	animated_sprite_2d.material.set_shader_parameter("amount", 0.0)
	explosion_sound.play()
	animated_sprite_2d.play("explosion")
	for body in blast_area.get_overlapping_bodies():
		if "knockback_component" in body and body.knockback_component != null:
			var knockback_direction := (body.global_position - global_position).normalized()
			body.knockback_component.apply_knockback(knockback_direction, knockback_force, 0.15)
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if body.is_in_group("Player"):
			body.handle_damage(self, damage)
	await animated_sprite_2d.animation_finished
	queue_free()
