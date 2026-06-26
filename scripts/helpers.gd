class_name Helpers extends RefCounted

# Collapse a (possibly diagonal) movement vector down to a single cardinal
# direction, picking the dominant axis.
static func get_cardinal_direction(dir: Vector2) -> Vector2:
	if abs(dir.x) > abs(dir.y):
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	return Vector2.DOWN if dir.y > 0 else Vector2.UP

# "up" / "down" / "left" / "right" suffix for the given cardinal direction.
static func get_direction_suffix(dir: Vector2) -> String:
	if dir == Vector2.UP: return "up"
	if dir == Vector2.LEFT: return "left"
	if dir == Vector2.RIGHT: return "right"
	return "down"
