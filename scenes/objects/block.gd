class_name PushableBlock extends AnimatableBody2D

# One bit per direction.
enum PushDir { UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8 }

@export var tile_size: int = 16
@export var move_speed: float = 120.0

## Directions this block may be pushed.
@export_flags("Up", "Down", "Left", "Right") var allowed_directions: int = PushDir.UP | PushDir.DOWN | PushDir.LEFT | PushDir.RIGHT

var _target := position
var _moving := false


func _ready() -> void:
	_target = position


func _physics_process(delta: float) -> void:
	if not _moving:
		return
	position = position.move_toward(_target, move_speed * delta)
	if position.distance_to(_target) < 0.5:
		position = _target
		_moving = false


## Called by the player. Returns true if the block moved.
func try_push(direction: Vector2i) -> bool:
	if _moving:
		return false
	if not _allows(direction):
		return false
	var step := Vector2(direction) * tile_size
	if _blocked(step):
		return false
	_target = position + step
	_moving = true
	return true


func _allows(direction: Vector2i) -> bool:
	var flag := 0
	match direction:
		Vector2i.UP: flag = PushDir.UP
		Vector2i.DOWN: flag = PushDir.DOWN
		Vector2i.LEFT: flag = PushDir.LEFT
		Vector2i.RIGHT: flag = PushDir.RIGHT
	return (allowed_directions & flag) != 0


func _blocked(step: Vector2) -> bool:
	# Cast from the block toward the destination; block the push if anything solid is there.
	var params := PhysicsRayQueryParameters2D.create(
		global_position, global_position + step)
	params.exclude = [self]
	params.collision_mask = collision_mask
	return not get_world_2d().direct_space_state.intersect_ray(params).is_empty()
