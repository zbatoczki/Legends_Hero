class_name Doorway extends Node2D

## Which door the player comes out of after a scene change. Static so it
## survives the scene swap (autoload-lite; only doors care about it).
static var spawn_door_name: String = ""

@export var locked: bool = false
@export var destructable: bool = false

## Same-scene destination. Leave empty when using target_scene.
@export var target_door: Doorway

## Cross-scene destination. Takes priority over target_door if both are set.
@export var target_scene: PackedScene
## Name of the Door node to spawn at in the target scene.
@export var target_door_name: String = ""

## Inventory item that opens this door. Must match the ItemResource name.
@export var key_item_name: String = "Key"

enum DOORWAY_DIRECTIONS { NORTH, SOUTH, EAST, WEST }
@export var doorway_direction: DOORWAY_DIRECTIONS

@onready var trigger: Area2D = %Trigger
@onready var blocker_shape: CollisionShape2D = %BlockerShape
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var spawn_point: Marker2D = %SpawnPoint


func _ready() -> void:
	_apply_locked_state()
	# If we just arrived from another scene through this door, place the player.
	if spawn_door_name == name:
		spawn_door_name = ""
		_place_player.call_deferred()
	
	if doorway_direction == DOORWAY_DIRECTIONS.NORTH or doorway_direction == DOORWAY_DIRECTIONS.SOUTH:
		trigger.rotate(deg_to_rad(90 if doorway_direction == DOORWAY_DIRECTIONS.NORTH else -90))
	elif doorway_direction == DOORWAY_DIRECTIONS.EAST:
		trigger.rotate(deg_to_rad(180))
	else:
		trigger.rotation = 0.0
		


func _place_player() -> void:
	var player := get_tree().get_first_node_in_group("Player") as Node2D
	if player != null:
		player.global_position = spawn_point.global_position


func _apply_locked_state() -> void:
	sprite_2d.frame = 0 if locked else 1
	# set_deferred: collision shapes can't change during physics callbacks.
	blocker_shape.set_deferred("disabled", not locked)


func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	if locked:
		if Inventory.has(key_item_name):
			Inventory.remove(key_item_name, 1)
			locked = false
			_apply_locked_state()
			# Player still has to walk through; this touch only unlocks.
		return
	_transition(body)


func _transition(player: Node2D) -> void:
	if target_scene != null:
		spawn_door_name = target_door_name
		get_tree().change_scene_to_packed.call_deferred(target_scene)
	elif target_door != null:
		player.set_deferred("global_position", target_door.get_node("Trigger/SpawnPoint").global_position)
