class_name InputComponent extends Node

var move_direction: Vector2 = Vector2.ZERO
var is_attacking := false
var is_blocking := false

func update() -> void:
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	is_blocking = Input.is_action_pressed("block");
	is_attacking =Input.is_action_just_pressed("attack")
