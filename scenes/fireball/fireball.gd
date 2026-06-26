class_name Fireball extends Area2D

var direction: Vector2

var speed: float = 100.0

func _process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
