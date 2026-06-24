class_name Player extends CharacterBody2D

@onready var input_component: InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var sword_swing_player: AudioStreamPlayer = $SwordSwing
@onready var sword_hitbox: Area2D = $DamageComponent

@export var sword_swing_tracks: Array[AudioStreamOggVorbis] = []

func _physics_process(delta: float) -> void:
	input_component.update()
	movement_component.direction = input_component.move_direction
	movement_component.is_blocking = input_component.is_blocking
	movement_component.is_attacking = input_component.is_attacking
	sword_hitbox.rotation = Vector2.UP.angle_to(movement_component.last_direction)
	if(input_component.is_attacking):
		swing_sword()
	movement_component.tick(delta)


func swing_sword() -> void:
	sword_hitbox.monitoring = true
	play_sword_swing_sound()
	await sword_swing_player.finished
	sword_hitbox.monitoring = false

func play_sword_swing_sound() -> void:
	sword_swing_player.stream = sword_swing_tracks.pick_random()
	sword_swing_player.play()
	


func _on_damage_component_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Enemy"): return
	
	var knockback_direction = (body.global_position - global_position).normalized()
	body.knockback_component.apply_knockback(knockback_direction, 300.0, 0.12)
	body.health_component.damage(1)
