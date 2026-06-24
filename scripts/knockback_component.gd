class_name KnockbackComponent extends Node

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func is_knockback_over() -> bool:
	return knockback_timer <= 0.0
	
func decrement_timer(amount: float) -> void:
	knockback_timer -= amount

func apply_knockback(direction: Vector2, force: float, duration: float) -> void:
	knockback = direction * force
	knockback_timer = duration
