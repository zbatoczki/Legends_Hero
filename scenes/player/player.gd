class_name Player extends CharacterBody2D

@onready var input_component: InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var sword_swing_player: AudioStreamPlayer = $SwordSwing
@onready var sword_hitbox: Area2D = $SwordHitBox
@onready var knockback_component: KnockbackComponent = $KnockbackComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_point: Marker2D = %ProjectileSpawnPoint
@onready var spawn_pivot: Node2D = $ProjectileSpawnPivot
@onready var interact_component: RayCast2D = $InteractComponent
@export var sword_swing_tracks: Array[AudioStreamOggVorbis] = []

## Items equipped to action slots A and B. Assigned by the inventory screen;
## may be null when a slot is empty.
@export var action_a: ItemResource
@export var action_b: ItemResource
@export var action_c: ItemResource

## Seconds the player must lean into a block before it slides one tile.
@export var push_delay: float = 0.25

var boomerang_thrown := false

# The block currently being pushed and how long we've been pushing it, so a
# block only slides after the player leans into it for `push_delay`.
var _push_block: PushableBlock = null
var _push_timer: float = 0.0
# Whether the player was leaning into a block last frame; drives the push
# animation. Detected after move_and_slide, so it feeds the sprite one frame later.
var _is_pushing: bool = false

## Cardinal direction the player is currently facing.
var facing_direction: Vector2:
	get: return movement_component.last_direction

func _ready() -> void:
	InputEventBus.action_a_triggered.connect(execute_action_a)
	InputEventBus.action_b_triggered.connect(execute_action_b)
	InputEventBus.action_c_triggered.connect(execute_action_c)


func _physics_process(delta: float) -> void:
	input_component.update()
	movement_component.direction = input_component.move_direction
	movement_component.is_blocking = input_component.is_blocking
	movement_component.is_attacking = input_component.is_attacking
	movement_component.is_pushing = _is_pushing
	var angle_to = Vector2.UP.angle_to(movement_component.last_direction)
	sword_hitbox.rotation = angle_to
	spawn_pivot.rotation = angle_to
	interact_component.rotation = angle_to
	if(input_component.is_attacking):
		swing_sword()
	movement_component.tick(delta)
	_handle_push(delta)


# Slides a pushable block one tile once the player has leaned into it for
# `push_delay`.
func _handle_push(delta: float) -> void:
	var block := _pushed_block()
	_is_pushing = block != null
	if block == null:
		_push_block = null
		_push_timer = 0.0
		return

	if block != _push_block:
		_push_block = block
		_push_timer = 0.0

	_push_timer += delta
	if _push_timer >= push_delay and block.try_push(Vector2i(facing_direction)):
		_push_timer = 0.0


# Gets the block the player is pushing, null otherwise
# Requires the player to be moving and directly moving into a block face
func _pushed_block() -> PushableBlock:
	if input_component.move_direction == Vector2.ZERO:
		return null
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is PushableBlock and collision.get_normal().dot(facing_direction) < -0.5:
			return collider as PushableBlock
	return null


func execute_action_a() -> void:
	use_action(action_a)


func execute_action_b() -> void:
	use_action(action_b)

func execute_action_c() -> void:
	use_action(action_c)
	boomerang_thrown = true

# Earliest time (in seconds) each equipped item may be used again.
var _action_ready_at: Dictionary[ItemResource, float] = {}

# Runs an equipped item's action. No-op when the slot is empty, the item has no
# action assigned, the action can't run (e.g. no ammo), or it's still cooling
# down. The bow additionally only fires when its draw isn't already playing.
func use_action(item: ItemResource) -> void:
	if item == null or item.action == null:
		return
		
	if not item.action.can_execute(self):
		return
		
	if _on_cooldown(item):
		return
		
	if item.name == "Bow":
		if _is_drawing_bow():
			return
		fire_bow(item.action)
	else:
		item.action.execute(self)
	_start_cooldown(item)


func _is_drawing_bow() -> bool:
	return animated_sprite_2d.is_playing() and animated_sprite_2d.animation.begins_with("bow")


func _on_cooldown(item: ItemResource) -> bool:
	return _action_ready_at.get(item, 0.0) > _now_seconds()


func _start_cooldown(item: ItemResource) -> void:
	if item.action.cooldown > 0.0:
		_action_ready_at[item] = _now_seconds() + item.action.cooldown


func _now_seconds() -> float:
	return Time.get_ticks_msec() / 1000.0


# Plays the bow draw and looses the arrow on the animation's release (final)
# frame, so the shot syncs with the draw instead of firing at the start. The
# shot is cancelled if the animation is interrupted (e.g. the player is hit).
func fire_bow(action: ActionResource) -> void:
	var animation := "bow_" + Helpers.get_direction_suffix(facing_direction)
	animated_sprite_2d.play(animation)
	var release_frame := animated_sprite_2d.sprite_frames.get_frame_count(animation) - 1
	while animated_sprite_2d.animation == animation and animated_sprite_2d.frame < release_frame:
		await animated_sprite_2d.frame_changed
	if animated_sprite_2d.animation == animation:
		action.execute(self)


# Spawns a projectile travelling in the player's facing direction. Used by ranged
# actions like the bow.
func fire_projectile(scene: PackedScene, speed: float) -> void:
	var projectile := scene.instantiate() as Projectile
	projectile.direction = facing_direction
	projectile.speed = speed
	get_parent().add_child(projectile)
	projectile.global_position = spawn_point.global_position


# Drops a scene at the player's position (e.g. a bomb). Returns the instance.
func place_object(scene: PackedScene) -> Node2D:
	var object := scene.instantiate() as Node2D
	get_parent().add_child(object)
	object.global_position = global_position
	return object


func swing_sword() -> void:
	sword_hitbox.monitoring = true
	play_sword_swing_sound()
	await sword_swing_player.finished
	sword_hitbox.monitoring = false

func play_sword_swing_sound() -> void:
	sword_swing_player.play()
	


func _on_damage_component_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Enemy"): return
	
	if "knockback_component" in body and body.knockback_component != null:
		var knockback_direction = (body.global_position - global_position).normalized()
		body.knockback_component.apply_knockback(knockback_direction, 300.0, 0.12)
	body.take_damage(1)


func _on_hitbox_body_entered(body: Node2D) -> void:
	handle_damage(body)
	


func _on_health_component_died() -> void:
	SoundEffectsPlayer.play_game_over_sound()
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	handle_damage(area)


func handle_damage(attacker: Node2D, damage_amount: int = 1, knockback_force: float = 100.0, knockback_duration: float = 0.25) -> void:
	if input_component.is_blocking: return
	var knockback_direction = (global_position - attacker.global_position).normalized()
	knockback_component.apply_knockback(knockback_direction, knockback_force, knockback_duration)
	SoundEffectsPlayer.play_damaged_sound()
	health_component.damage(damage_amount)


func _on_damaged() -> void:
	animated_sprite_2d.material.set_shader_parameter("amount", 1.0)
	await get_tree().create_timer(0.1).timeout
	animated_sprite_2d.material.set_shader_parameter("amount", 0)
