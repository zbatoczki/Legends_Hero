class_name MovementComponent extends Node

@onready var knockback_component: KnockbackComponent = %KnockbackComponent

@export var body: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var speed: float = 50.0

var direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.UP
var is_blocking: bool = false
var is_attacking: bool = false
var is_pushing: bool = false

func tick(delta: float) -> void:
	if body == null: return

	# Let action animations (attack, bow) play out before accepting movement again.
	# Facing is intentionally left untouched here so it stays locked to the
	# direction the action started in (e.g. an arrow fires the way the bow draws).
	if sprite.is_playing() and (sprite.animation.begins_with("attack") or sprite.animation.begins_with("bow")):
		body.velocity = Vector2.ZERO
		body.move_and_slide()
		return

	# Remember which way we're facing whenever we actually move, so we can
	# keep facing that way while idle or attacking.
	if direction != Vector2.ZERO:
		last_direction = Helpers.get_cardinal_direction(direction)

	if is_attacking:
		body.velocity = Vector2.ZERO
		set_attack_sprite()
	else:
		body.velocity = direction * speed
		set_walking_sprite()
		
	if not knockback_component.is_knockback_over():
		knockback_component.decrement_timer(delta)
		body.velocity = knockback_component.knockback
	else:
		knockback_component.knockback = Vector2.ZERO

	body.move_and_slide()


func set_attack_sprite() -> void:
	sprite.play("attack_" + Helpers.get_direction_suffix(last_direction))

func set_walking_sprite() -> void:
	# Pushing a block takes visual priority over the shield-block stance.
	var prefix := "walk"
	if is_pushing:
		prefix = "push"
	elif is_blocking:
		prefix = "block"
	var anim := prefix + "_" + Helpers.get_direction_suffix(last_direction)

	if direction == Vector2.ZERO:
		sprite.animation = anim
		sprite.pause()
	else:
		sprite.play(anim)
