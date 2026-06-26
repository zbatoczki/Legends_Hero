class_name MovementComponent extends Node

@onready var knockback_component: KnockbackComponent = %KnockbackComponent

@export var body: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var speed: float = 50.0

var direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.UP
var is_blocking: bool = false
var is_attacking: bool = false

func tick(delta: float) -> void:
	if body == null: return

	# Remember which way we're facing whenever we actually move, so we can
	# keep facing that way while idle or attacking.
	if direction != Vector2.ZERO:
		last_direction = _cardinal(direction)

	# Let attack animation play out before accepting movement again.
	if sprite.is_playing() and sprite.animation.begins_with("attack"):
		body.velocity = Vector2.ZERO
		body.move_and_slide()
		return

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

# Collapse a (possibly diagonal) movement vector down to a single cardinal
# direction, picking the dominant axis.
func _cardinal(dir: Vector2) -> Vector2:
	if abs(dir.x) > abs(dir.y):
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	return Vector2.DOWN if dir.y > 0 else Vector2.UP

# "up" / "down" / "left" / "right" suffix for the given cardinal direction.
func _suffix(dir: Vector2) -> String:
	if dir == Vector2.UP: return "up"
	if dir == Vector2.LEFT: return "left"
	if dir == Vector2.RIGHT: return "right"
	return "down"

func set_attack_sprite() -> void:
	sprite.play("attack_" + _suffix(last_direction))

func set_walking_sprite() -> void:
	var prefix := "block" if is_blocking else "walk"
	var anim := prefix + "_" + _suffix(last_direction)

	if direction == Vector2.ZERO:
		sprite.animation = anim
		sprite.pause()
	else:
		sprite.play(anim)
