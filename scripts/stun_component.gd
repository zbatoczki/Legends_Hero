class_name StunComponent extends Node

## Freezes the owning enemy for a duration when stun(duration) is called.
## Optional per-enemy: code that supports stunning treats a missing
## StunComponent as "can never be stunned".

signal stunned(duration: float)
signal stun_ended

## Optional. Paused while stunned, resumed when the stun ends.
@export var animated_sprite: AnimatedSprite2D

var _time_left: float = 0.0


func is_stunned() -> bool:
	return _time_left > 0.0


## Starts a stun, or extends the current one if the new duration lasts longer.
func stun(duration: float) -> void:
	if duration <= 0.0:
		return
	var was_stunned := is_stunned()
	_time_left = maxf(_time_left, duration)
	if not was_stunned:
		if animated_sprite != null:
			animated_sprite.pause()
		stunned.emit(duration)


func _physics_process(delta: float) -> void:
	if not is_stunned():
		return
	_time_left -= delta
	if _time_left <= 0.0:
		_time_left = 0.0
		if animated_sprite != null:
			animated_sprite.play()
		stun_ended.emit()
