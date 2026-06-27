class_name PickupItem extends Area2D

signal item_picked_up(item: ItemResource)

@export var item_resource: ItemResource

@onready var animated_texture: AnimatedSprite2D = $AnimatedTexture
@onready var static_texture: Sprite2D = $StaticTexture
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var active_texture: Node2D

func _ready() -> void:
	if item_resource == null:
		printerr("Item resource not provided")
	set_item_texture()
	collision_shape_2d.shape = item_resource.collision_shape


func set_item_texture() -> void:
	if item_resource.animated_texture != null:
		animated_texture.sprite_frames = item_resource.animated_texture
	if item_resource.static_texture != null:
		static_texture.texture = item_resource.static_texture	
	if animated_texture.sprite_frames == null and static_texture.texture == null:
		printerr("Textures are not provided in the item resource")
	if animated_texture.sprite_frames != null:
		static_texture.visible = false
	else:  
		animated_texture.visible = false


func _on_player_entered(_body: Node2D) -> void:
	SoundEffectsPlayer.play_item_sound(item_resource.sound_effect)
	item_picked_up.emit(item_resource)
	queue_free()
