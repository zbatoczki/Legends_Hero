class_name HealthComponent extends Node

signal damaged
signal health_changed(currentHealth: int, maxHealth: int)
signal died

@export var max_health: int = 10
@export var current_health: int = 0

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

	
func damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	damaged.emit()
	if(current_health == 0):
		died.emit()

func heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)
