class_name Enemy extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

## Optional. Enemies without a StunComponent child cannot be stunned.
@onready var stun_component: StunComponent = get_node_or_null("StunComponent")

@export var death_effect: PackedScene = preload("uid://d383uqewghmuh")

var player: Player

func get_player() -> Player:
	if player == null:
		player = get_tree().get_first_node_in_group("Player") as Player
	return player


## Returns a normalized Vector2 direction relative to the player's position
func get_cardinal_direction_to_player() -> Vector2:
	var target := get_player()
	if target == null:
		return Vector2.ZERO
	return Helpers.get_cardinal_direction(target.global_position - global_position)


func take_damage(amount: int, stun_duration: float = 0.0) -> void:
	if stun_duration > 0.0 and stun_component != null:
		stun_component.stun(stun_duration)
	var is_boss = self.is_in_group("Boss")
	SoundEffectsPlayer.play_damaged_sound(is_boss)
	health_component.damage(amount)


func is_stunned() -> bool:
	return stun_component != null and stun_component.is_stunned()


func _on_damaged() -> void:
	play_damage_flash()


func play_damage_flash() -> void:
	if animated_sprite_2d == null or animated_sprite_2d.material == null: 
		return
	animated_sprite_2d.material.set_shader_parameter("amount", 1.0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite_2d.material.set_shader_parameter("amount", 0)


func _on_died() -> void:
	collision_layer = 0
	var death_scene_instance = death_effect.instantiate()
	death_scene_instance.global_position = global_position
	get_parent().add_child(death_scene_instance)
	queue_free()
