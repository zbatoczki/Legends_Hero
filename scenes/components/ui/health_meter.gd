class_name HealthMeter extends Control

@export var player: Player

@onready var meter_bar: HBoxContainer = %MeterBar

const HEART_METER = preload("uid://uadxcb50tkw5")


func _ready() -> void:
	if player == null: return
	for child in meter_bar.get_children():
		child.queue_free()
	for i in range(player.health_component.current_health):
		increment_meter()
	player.health_component.health_changed.connect(_on_health_changed)


func decrement_meter() -> void:
	if meter_bar.get_child_count() == 0: return
	var bar_to_remove = meter_bar.get_child(-1)
	meter_bar.remove_child(bar_to_remove)
	bar_to_remove.queue_free()


func increment_meter() -> void:
	var heart := TextureRect.new()
	heart.texture = HEART_METER
	heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	heart.custom_minimum_size = Vector2(8, 8)
	meter_bar.add_child(heart)


func _on_health_changed(currentHealth: int, _maxHealth: int) -> void:
	var difference = meter_bar.get_child_count() - currentHealth
	for i in range(abs(difference)):
		if difference > 0:
			decrement_meter()
		elif difference < 0:
			increment_meter()
