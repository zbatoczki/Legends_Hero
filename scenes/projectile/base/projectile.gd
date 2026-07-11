class_name Projectile extends Area2D

## Rotate the whole projectile to point along its travel direction (e.g. arrows).
@export var orient_to_direction: bool = false
## Added to the orientation, in degrees. Use this when the sprite's default art
## does not point right (e.g. 90 for art that points up).
@export var orient_offset_degrees: float = 0.0
## Damage dealt to bodies in target_group on contact. 0 = harmless on impact.
@export var damage: int = 0
## Only bodies in this group take damage (e.g. "Enemy"). Empty = damage nobody.
@export var target_group: String = ""
## Knockback applied to a damaged body. 0 = none.
@export var knockback_force: float = 0.0

var direction: Vector2
var speed: float = 100.0


func _ready() -> void:
	if orient_to_direction:
		rotation = direction.angle() + deg_to_rad(orient_offset_degrees)


func _process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if target_group != "" and body.is_in_group(target_group):
		# Targets get a chance to swat the projectile away before it deals damage.
		var deflected: bool = body.has_method("try_deflect_projectile") \
				and body.try_deflect_projectile(self)
		if not deflected:
			_hit(body)
	queue_free()


func _hit(body: Node2D) -> void:
	if knockback_force > 0.0 and "knockback_component" in body and body.knockback_component != null:
		var knockback_direction := (body.global_position - global_position).normalized()
		body.knockback_component.apply_knockback(knockback_direction, knockback_force, 0.12)
	if body.has_method("take_damage"):
		body.take_damage(damage)
