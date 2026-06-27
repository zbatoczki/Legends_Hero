class_name HealthMeter extends Control

@export var player: Player

@onready var meter_bar: HBoxContainer = %MeterBar

const HEART_METER = preload("uid://uadxcb50tkw5")


func _ready() -> void:
	for i in range(player.health_component.current_health):
		increment_meter()
	player.health_component.health_changed.connect(_on_health_changed)


func decrement_meter() -> void:
	if meter_bar.get_child_count() == 0: return
	var bar_to_remove = meter_bar.get_child(-1)
	meter_bar.remove_child(bar_to_remove)
	bar_to_remove.queue_free()


func increment_meter() -> void:
	var textureRect = TextureRect.new()
	textureRect.texture = HEART_METER
	meter_bar.add_child(textureRect)


func _on_health_changed(currentHealth: int, _maxHealth: int) -> void:
	var difference = meter_bar.get_child_count() - currentHealth
	for i in range(abs(difference)):
		if difference > 0:
			decrement_meter()
		elif difference < 0:
			increment_meter()
