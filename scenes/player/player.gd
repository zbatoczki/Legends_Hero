class_name Player extends CharacterBody2D

@onready var input_component: InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var sword_swing_player: AudioStreamPlayer = $SwordSwing

@export var sword_swing_tracks: Array[AudioStreamOggVorbis] = []

func _physics_process(delta: float) -> void:
	input_component.update()
	movement_component.direction = input_component.move_direction
	movement_component.is_blocking = input_component.is_blocking
	movement_component.is_attacking = input_component.is_attacking
	if(input_component.is_attacking): play_sword_swing()
	movement_component.tick(delta)

func play_sword_swing() -> void:
	sword_swing_player.stream = sword_swing_tracks.pick_random()
	sword_swing_player.play()
