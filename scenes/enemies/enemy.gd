class_name Enemy extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const DEATH_COMPONENT: PackedScene = preload("uid://d383uqewghmuh")

var player: Player


func get_player() -> Player:
	if player == null:
		player = get_tree().get_first_node_in_group("Player") as Player
	return player



func get_cardinal_direction_to_player() -> Vector2:
	var target := get_player()
	if target == null:
		return Vector2.ZERO
	return Helpers.get_cardinal_direction(target.global_position - global_position)


func take_damage(amount: int) -> void:
	SoundEffectsPlayer.play_damaged_sound()
	health_component.damage(amount)


func _on_damaged() -> void:
	if animated_sprite_2d == null or animated_sprite_2d.material == null: 
		return
	animated_sprite_2d.material.set_shader_parameter("amount", 1.0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite_2d.material.set_shader_parameter("amount", 0)


func _on_died() -> void:
	collision_layer = 0
	var death_scene_instance = DEATH_COMPONENT.instantiate()
	death_scene_instance.global_position = global_position
	get_parent().add_child(death_scene_instance)
	queue_free()
