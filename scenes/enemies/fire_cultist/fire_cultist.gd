class_name FireCultist extends Enemy

@onready var fireball_cast_animation: AnimatedSprite2D = $FireballCastAnimation
@onready var body_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var fireball_spawn_position: Marker2D = %FireballSpawnPosition
@onready var fireball_spawn_anchor: Node2D = $FireballSpawnAnchor
@onready var enemy_movement_component: EnemyMovementComponent = $EnemyMovementComponent

const FIREBALL: PackedScene = preload("uid://c42ge5awb3rpv")

func _ready() -> void:
	fireball_cast_animation.visible = false;
	enemy_movement_component.go_to_next_position()

func _on_movement_timer_timeout() -> void:
	enemy_movement_component.go_to_next_position()
	cast_firebal()

func cast_firebal() -> void:
	body_animation.play()
	face_player()
	await play_cast_animation()
	spawn_fireball()
	
func face_player() -> void:
	var direction = get_cardinal_direction_to_player()
	if direction == Vector2.ZERO: return
	var angle_to = Vector2.DOWN.angle_to(direction)
	fireball_cast_animation.rotation = angle_to
	fireball_spawn_anchor.rotation = angle_to
	body_animation.play("cast_%s" % [Helpers.get_direction_suffix(direction)])
	
func play_cast_animation() -> void:
	fireball_cast_animation.visible = true
	fireball_cast_animation.play("default")
	await fireball_cast_animation.animation_finished
	fireball_cast_animation.visible = false
	body_animation.stop()
	
func spawn_fireball() -> void:
	var target := get_player()
	if target == null: return
	var fireball_instance = FIREBALL.instantiate()
	fireball_instance.global_position = fireball_spawn_position.global_position
	fireball_instance.direction = (target.global_position - fireball_instance.global_position).normalized()
	get_parent().add_child(fireball_instance)
