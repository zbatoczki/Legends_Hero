extends Area2D

@export var speed: float = 150.0
@export var travel_range: float = 250.0
@export var damage: int = 1


var player: Player

var _initial_position: Vector2
var _is_returning: bool = false
var _distance_traveled: float = 0.0
var _direction_to_travel: Vector2


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	_initial_position = global_position
	_direction_to_travel = player.facing_direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not _is_returning:
		var last_position = global_position
		global_position += _direction_to_travel * speed * delta
		_distance_traveled += last_position.distance_squared_to(global_position)
		if _distance_traveled >= travel_range:
			_is_returning = true
	elif global_position.distance_squared_to(player.global_position) > 10:
		_direction_to_travel = global_position.direction_to(player.global_position)
		global_position += _direction_to_travel * speed * delta
	else:
		player.boomerang_thrown = false
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(1)
		_is_returning = true
