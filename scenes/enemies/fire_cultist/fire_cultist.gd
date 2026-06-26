class_name  FireCultist extends CharacterBody2D

@onready var fireball_cast_animation: AnimatedSprite2D = $FireballCastAnimation
@onready var health_component: HealthComponent = $HealthComponent
@onready var body_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var fireball_spawn_position: Marker2D = %FireballSpawnPosition
@onready var fireball_spawn_anchor: Node2D = $FireballSpawnAnchor

var death_component: PackedScene = preload("res://scenes/components/enemy_death_component.tscn")
const FIREBALL: PackedScene = preload("uid://c42ge5awb3rpv")

var player: Player

func _ready() -> void:
	fireball_cast_animation.visible = false;
	teleport()

func take_damage(amount: int) -> void:
	SoundEffectsPlayer.play_damaged_sound()
	health_component.damage(amount)

func _on_died() -> void:
	collision_layer = 0
	var death_scene_instance = death_component.instantiate()
	death_scene_instance.global_position = global_position
	get_parent().add_child(death_scene_instance)
	queue_free()

func teleport() -> void:
	var random_x_position = global_position.x + randf_range(-50, 50)
	var random_y_position = global_position.y + randf_range(-50, 50)
	global_position = Vector2(random_x_position, random_y_position)

func _on_movement_timer_timeout() -> void:
	teleport()
	cast_firebal()

func cast_firebal() -> void:
	body_animation.play()
	face_player()
	await play_cast_animation()
	spawn_fireball()
	
func face_player() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Player") as Player
	if player == null: return
	var direction = _cardinal(player.global_position - global_position)
	var angle_to = Vector2.DOWN.angle_to(direction)
	fireball_cast_animation.rotation = angle_to
	fireball_spawn_anchor.rotation = angle_to
	body_animation.play("cast_%s" % [_suffix(direction)])
	
func play_cast_animation() -> void:
	fireball_cast_animation.visible = true
	fireball_cast_animation.play("default")
	await fireball_cast_animation.animation_finished
	fireball_cast_animation.visible = false
	body_animation.stop()
	
func spawn_fireball() -> void:
	if player == null: return
	var fireball_instance = FIREBALL.instantiate()
	fireball_instance.global_position = fireball_spawn_position.global_position
	fireball_instance.direction = (player.global_position - fireball_instance.global_position).normalized()
	get_parent().add_child(fireball_instance)
	
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
