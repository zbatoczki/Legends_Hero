class_name FireCultist extends Enemy

@onready var fireball_cast_animation: AnimatedSprite2D = $FireballCastAnimation
@onready var body_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_movement_component: EnemyMovementComponent = $EnemyMovementComponent
@onready var projectile_controller_componenet: Node2D = $ProjectileControllerComponenet


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
	projectile_controller_componenet.rotation = angle_to
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
	var target_direction = (target.global_position - projectile_controller_componenet.get_spawn_point_position()).normalized()
	projectile_controller_componenet.launch_projectile(target_direction)
