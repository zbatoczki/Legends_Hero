class_name Room extends Area2D

## Clamps the player's camera to this room's rect while the player is inside.

signal player_entered_room
signal room_cleared

@onready var shape: CollisionShape2D = $CollisionShape2D

@export var enemies_to_destroy: Array[Enemy] = []
@export var is_boss_room: bool = false

func _ready() -> void:
	_connect_enemy_signals.call_deferred()


func _connect_enemy_signals() -> void:
	for enemy in enemies_to_destroy:
		enemy.health_component.died.connect(_on_enemy_destroyed.bind(enemy))


func _on_body_entered(body: Node2D) -> void:
	clamp_camera(body)
	player_entered_room.emit()


func clamp_camera(body: Node2D) -> void:
	if body is not Player:
		return
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var rect := global_rect()
	camera.limit_left = int(rect.position.x)
	camera.limit_top = int(rect.position.y)
	camera.limit_right = int(rect.end.x)
	camera.limit_bottom = int(rect.end.y)


func global_rect() -> Rect2:
	var size: Vector2 = shape.shape.size
	return Rect2(shape.global_position - size / 2.0, size)


func _on_enemy_destroyed(enemy: Enemy) -> void:
	enemies_to_destroy.erase(enemy)
	if enemies_to_destroy.is_empty():
		room_cleared.emit()
