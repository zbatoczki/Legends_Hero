extends Enemy

@export var boss_room: Room

@onready var enemy_movement_component: EnemyMovementComponent = $EnemyMovementComponent
@onready var player_detection: Area2D = $PlayerDetection
@onready var swing_sound: AudioStreamPlayer = $SwingSound
@onready var smash_sound: AudioStreamPlayer = $SmashSound
@onready var damage_hitbox: Area2D = $DamageHitbox
@onready var attack_positions := {
	Vector2.DOWN: $AttackDownPosition,
	Vector2.UP: $AttackUpPosition,
	Vector2.LEFT: $AttackLeftPosition,
	Vector2.RIGHT: $AttackRightPosition,
}


func _ready() -> void:
	if boss_room != null:
		boss_room.player_entered_room.connect(_on_player_entered_boss_room)
	if stun_component != null:
		stun_component.stunned.connect(_on_stunned)
		stun_component.stun_ended.connect(_on_stun_ended)


func attack() -> void:
	if is_stunned():
		return
	enemy_movement_component.enable_movement(false)
	damage_hitbox.monitoring = true
	#face player
	var direction_to_face = get_cardinal_direction_to_player()
	set_damage_hitbox_position(direction_to_face)
	#play attack animation
	animated_sprite_2d.play("attack_" + Helpers.get_direction_suffix(direction_to_face))
	swing_sound.play()


func _on_player_detection_body_entered(_body: Node2D) -> void:
	attack()


func _on_player_detection_body_exited(_body: Node2D) -> void:
	await get_tree().create_timer(0.5).timeout
	enemy_movement_component.enable_movement(true)


func _on_animated_sprite_2d_animation_finished() -> void:
	if not animated_sprite_2d.animation.begins_with("attack"):
		return
		
	swing_sound.stop()
	smash_sound.play()
	damage_hitbox.monitoring = false
	enemy_movement_component.enable_movement(true)


func set_damage_hitbox_position(direction: Vector2) -> void:
	damage_hitbox.position = attack_positions[direction].position
	damage_hitbox.rotation = PI / 2 if direction.y != 0 else 0.0


func _on_damage_hitbox_player_entered(_player: Player) -> void:
	player.handle_damage(self, 3, 200.0)


# Swats player projectiles (arrows, etc.) out of the air with an attack swing.
# Returning true tells the projectile it dealt no damage; it frees itself.
# While stunned the boss can't react, so projectiles hit normally.
func try_deflect_projectile(_projectile: Projectile) -> bool:
	if is_stunned():
		return false
	attack()
	return true


# Cancel whatever the boss was doing; the sprite is paused by StunComponent
# and EnemyMovementComponent halts on its own while the stun lasts.
func _on_stunned(_duration: float) -> void:
	damage_hitbox.monitoring = false
	swing_sound.stop()


func _on_stun_ended() -> void:
	if player_detection.has_overlapping_bodies():
		attack()
	else:
		enemy_movement_component.enable_movement(true)
		
func _on_died() -> void:
	collision_layer = 0
	process_mode = Node.PROCESS_MODE_DISABLED
	_flash_until_freed()
	await get_tree().create_timer(2).timeout
	var death_scene_instance: BossDeathComponent = death_effect.instantiate()
	death_scene_instance.global_position = global_position
	get_parent().add_child(death_scene_instance)
	death_scene_instance.boss_death_complete.connect(func(): queue_free())


func _on_player_entered_boss_room() -> void:
	await get_tree().create_timer(1).timeout
	SoundEffectsPlayer.play_boss_music()
	process_mode = Node.PROCESS_MODE_INHERIT


func _flash_until_freed() -> void:
	while not is_queued_for_deletion():
		await play_damage_flash()          # 0.1s white, then back to normal
		await get_tree().create_timer(0.05).timeout  # 0.1s gap between flashes
