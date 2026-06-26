class_name EnemyMovementComponent extends Node

## Moves a CharacterBody2D around, taking knockback into account if applied.
## Behaviour depends on movement_mode:
##   WANDER   - walk to random nearby positions
##   TELEPORT - snap instantly to random nearby positions
##   FOLLOW   - walk toward the player's current position

enum MovementMode { WANDER, TELEPORT, FOLLOW }

@export var body: CharacterBody2D

## Optional.
@export var knockback_component: KnockbackComponent

@export var movement_mode: MovementMode = MovementMode.WANDER

## When false the component never picks targets on its own; call
## go_to_next_position() yourself (e.g. a fire cultist teleporting as it casts).
## Ignored in FOLLOW mode, which always tracks the player.
@export var auto_retarget: bool = true

@export var speed: float = 25.0
@export var wander_radius: float = 24.0

## Seconds between picking new wander targets (a fresh value is rolled each time).
@export var min_wander_interval: float = 1.0
@export var max_wander_interval: float = 3.0

var _retarget_timer: float = 0.0
var target_position: Vector2
var _player: Node2D


func _ready() -> void:
	target_position = body.global_position
	_reset_retarget_timer()


func _physics_process(delta: float) -> void:
	if _is_being_knocked_back():
		knockback_component.decrement_timer(delta)
		body.velocity = knockback_component.knockback
		body.move_and_slide()
		return

	if knockback_component != null:
		knockback_component.knockback = Vector2.ZERO

	if movement_mode == MovementMode.FOLLOW:
		_track_player()
	elif auto_retarget:
		_advance_wander(delta)

	# Teleporting bodies already snapped to their target on retarget, so there is
	# nothing to drive per-frame. The others steer toward the target.
	if movement_mode != MovementMode.TELEPORT:
		body.velocity = velocity_to_target()
		body.move_and_slide()


func _is_being_knocked_back() -> bool:
	return knockback_component != null and not knockback_component.is_knockback_over()


# Count down to the next retarget, but only while we're free to move so a body
# doesn't immediately re-pick a target the instant knockback ends.
func _advance_wander(delta: float) -> void:
	_retarget_timer -= delta
	if _retarget_timer <= 0.0:
		go_to_next_position()


# Aim at where the player currently is. Keeps the last target if there's no
# player in the scene yet.
func _track_player() -> void:
	var player := _get_player()
	if player != null:
		target_position = player.global_position


# Pick a new random point within wander_radius and either head for it or, in
# teleport mode, snap to it immediately. Safe to call manually.
func go_to_next_position() -> void:
	pick_random_position()
	if movement_mode == MovementMode.TELEPORT:
		body.global_position = target_position
	_reset_retarget_timer()


func _reset_retarget_timer() -> void:
	_retarget_timer = randf_range(min_wander_interval, max_wander_interval)


func velocity_to_target() -> Vector2:
	if body.global_position.distance_to(target_position) <= 1.0:
		return Vector2.ZERO
	return body.global_position.direction_to(target_position) * speed


# Pick a new random point within wander_radius of where we are now.
func pick_random_position() -> void:
	target_position = body.global_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius),
	)


func _get_player() -> Node2D:
	if _player == null:
		_player = get_tree().get_first_node_in_group("Player") as Node2D
	return _player
