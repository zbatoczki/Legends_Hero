class_name InputComponent extends Node

var move_direction: Vector2 = Vector2.ZERO
var is_attacking := false
var is_blocking := false

func update() -> void:
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	is_blocking = Input.is_action_pressed("block");
	is_attacking =Input.is_action_just_pressed("attack")
	if Input.is_action_just_pressed("open_inventory"):
		InputEventBus.emit_inventory_toggled()
	if Input.is_action_just_pressed("execute_action_a"):
		InputEventBus.emit_action_a_triggered()
	if Input.is_action_just_pressed("execute_action_b"):
		InputEventBus.emit_action_b_triggered()
