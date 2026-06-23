class_name Player extends CharacterBody2D

@onready var input_component: InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent

func _physics_process(delta: float) -> void:
	input_component.update()
	movement_component.direction = input_component.move_direction
	movement_component.is_blocking = input_component.is_blocking
	movement_component.is_attacking = input_component.is_attacking
	movement_component.tick(delta)
