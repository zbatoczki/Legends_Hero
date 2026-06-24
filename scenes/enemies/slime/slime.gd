class_name Slime extends CharacterBody2D

@onready var random_movement_component: RandomMovementComponent = $RandomMovementComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_sound: AudioStreamPlayer = $DamageSound
@onready var knockback_component: KnockbackComponent = $KnockbackComponent


func _ready() -> void:
	random_movement_component.target_position = global_position

func _physics_process(delta: float) -> void:
	if not knockback_component.is_knockback_over():
		knockback_component.decrement_timer(delta)
		velocity = knockback_component.knockback
	else:
		knockback_component.knockback = Vector2.ZERO
		velocity = random_movement_component.wander_velocity()
	move_and_slide()

func take_damage(amount: int) -> void:
	SoundEffectsPlayer.play_damaged_sound()
	health_component.damage(amount)

func _on_died() -> void:
	call_deferred("queue_free")

func _on_random_movement_timer_timeout() -> void:
	if not knockback_component.is_knockback_over():
		return
	random_movement_component.move_randomly()
