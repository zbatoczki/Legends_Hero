class_name EnemyMovementComponent extends Node

## Moves a CharacterBody2D around, taking knockback into account if applied.
## Behaviour depends on movement_mode:
##   WANDER   - walk to random nearby positions
##   TELEPORT - snap instantly to random nearby positions
##   FOLLOW   - walk toward the player's current position

enum MovementMode { WANDER, TELEPORT, FOLLOW }

@export var body: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var play_direction_animation : bool = true

## Optional.
@export var knockback_component: KnockbackComponent

## Optional. While this reports stunned, the body stops moving and retargeting.
@export var stun_component: StunComponent

@export var movement_mode: MovementMode = MovementMode.WANDER

## Will move movement in intervals, similar to WANDER mode
@export var break_follow_movement: bool = false

## When false the component never picks targets on its own; call
## go_to_next_position() yourself (e.g. a fire cultist teleporting as it casts).
## Ignored in FOLLOW mode, which always tracks the player.
@export var auto_retarget: bool = true

@export var speed: float = 25.0
@export var wander_radius: float = 24.0

## Seconds between picking new wander targets (a fresh value is rolled each time).
@export var min_wander_interval: float = 1.0
@export var max_wander_interval: float = 3.0

## Optional. Keeps every target inside the painted area of this layer. 
## If empty, the first node in the "MovementBounds" group is used.
@export var bounds_layer: TileMapLayer
@export var bounds_margin: float = 8.0

var _retarget_timer: float = 0.0
var _player: Node2D
var _last_direction: Vector2
var allow_moving: bool = true
var target_position: Vector2

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

	if stun_component != null and stun_component.is_stunned():
		body.velocity = Vector2.ZERO
		return

	if auto_retarget:
		_advance_wander(delta)

	# Teleporting bodies already snapped to their target on retarget, so there is
	# nothing to drive per-frame. The others steer toward the target.
	if allow_moving and movement_mode != MovementMode.TELEPORT:
		body.velocity = velocity_to_target()
		body.move_and_slide()


func enable_movement(enable: bool) -> void:
	allow_moving = enable
	if not allow_moving:
		body.velocity = Vector2.ZERO
	else:
		animated_sprite.play("move_down")


func _is_being_knocked_back() -> bool:
	return knockback_component != null and not knockback_component.is_knockback_over()


# Count down to the next retarget, but only while we're free to move so a body
# doesn't immediately re-pick a target the instant knockback ends.
func _advance_wander(delta: float) -> void:
	_retarget_timer -= delta
	if _retarget_timer <= 0.0:
		go_to_next_position()


func _get_player() -> Node2D:
	if _player == null:
		_player = get_tree().get_first_node_in_group("Player") as Node2D
	return _player


# Aim at where the player currently is. Keeps the last target if there's no
# player in the scene yet.
func _track_player() -> void:
	var player: Node2D = _get_player()
	if player != null:
		target_position = _clamp_to_bounds(player.global_position)


# Pick a new random point within wander_radius of where we are now.
func pick_random_position() -> void:
	target_position = _clamp_to_bounds(body.global_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius),
	))


# Pick a new random point within wander_radius and either head for it or, in
# teleport mode, snap to it immediately. Safe to call manually.
func go_to_next_position() -> void:
	if movement_mode == MovementMode.FOLLOW:
		_track_player()
	else:
		pick_random_position()
	if movement_mode == MovementMode.TELEPORT:
		body.global_position = target_position
	elif animated_sprite != null and play_direction_animation:
		var cardinal_direction = Helpers.get_cardinal_direction(_last_direction)
		var animation_name = "move_" + Helpers.get_direction_suffix(cardinal_direction)
		animated_sprite.play(animation_name)
	_reset_retarget_timer()


func _reset_retarget_timer() -> void:
	_retarget_timer = randf_range(min_wander_interval, max_wander_interval)


func velocity_to_target() -> Vector2:
	if body.global_position.distance_to(target_position) <= 1.0:
		return Vector2.ZERO
	_last_direction = body.global_position.direction_to(target_position)
	return _last_direction * speed


func _get_bounds_layer() -> TileMapLayer:
	if bounds_layer == null:
		bounds_layer = get_tree().get_first_node_in_group("MovementBounds") as TileMapLayer
	return bounds_layer


# Clamp a world position to the painted cells of the bounds layer (minus the
# margin). Returns pos unchanged if no bounds layer is configured.
func _clamp_to_bounds(pos: Vector2) -> Vector2:
	var layer := _get_bounds_layer()
	if layer == null:
		return pos
	var rect := layer.get_used_rect()
	if rect.size == Vector2i.ZERO:
		return pos
	var cell := Vector2(layer.tile_set.tile_size)
	var min_world := layer.to_global(layer.map_to_local(rect.position) - cell / 2.0)
	var max_world := layer.to_global(layer.map_to_local(rect.end - Vector2i.ONE) + cell / 2.0)
	return Vector2(
		clampf(pos.x, min_world.x + bounds_margin, max_world.x - bounds_margin),
		clampf(pos.y, min_world.y + bounds_margin, max_world.y - bounds_margin),
	)
