# PushableBlock.gd
class_name PushableBlock extends StaticBody2D

@export var tile_size: int = 16
@export var move_speed: float = 120.0   # visual glide; 0 = instant snap

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

## Called by the player. Returns true if the block actually moved.
func try_push(dir: Vector2i) -> bool:
	if _moving:
		return false
	var step := Vector2(dir) * tile_size
	if _blocked(step):
		return false
	_target = position + step
	_moving = true
	return true

func _blocked(step: Vector2) -> bool:
	# Cast from the block toward the destination; block the push if anything solid is there.
	var params := PhysicsRayQueryParameters2D.create(
		global_position, global_position + step)
	params.exclude = [self]
	params.collision_mask = collision_mask
	return not get_world_2d().direct_space_state.intersect_ray(params).is_empty()
