class_name RandomMovementComponent extends Node

@export var body: CharacterBody2D
@export var speed: float = 25.0
@export var wander_radius: float = 24.0

var target_position: Vector2

# Steady-speed step toward the current wander target, stopping once we're
# close enough to avoid jittering back and forth across it.
func wander_velocity() -> Vector2:
	if body.global_position.distance_to(target_position) <= 1.0:
		return Vector2.ZERO
	return body.global_position.direction_to(target_position) * speed

# Pick a new random point within wander_radius of where we are now.
func move_randomly() -> void:
	target_position = body.global_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius),
	)
