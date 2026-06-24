class_name Player extends CharacterBody2D

@onready var input_component: InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var sword_swing_player: AudioStreamPlayer = $SwordSwing
@onready var sword_hitbox: Area2D = $DamageComponent
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var health_component: HealthComponent = $HealthComponent

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
	body.take_damage(1)


func _on_hitbox_body_entered(body: Node2D) -> void:
	var knockback_direction = (global_position - body.global_position).normalized()
	knockback_component.apply_knockback(knockback_direction, 100.0, 0.25)
	SoundEffectsPlayer.play_damaged_sound()
	health_component.damage(1)
	


func _on_health_component_died() -> void:
	SoundEffectsPlayer.play_game_over_sound()
	queue_free()
