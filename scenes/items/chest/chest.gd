extends Interactable

@export var item: ItemResource
@export var _is_visible := true

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var item_end_position: Vector2 = $ItemEndPosition.global_position
@onready var sound: AudioStreamPlayer = $AudioStreamPlayer

var _is_open := false

func _ready() -> void:
	sprite_2d.frame = 0
	if item == null:
		push_warning("No item was assigned to the chest.")
	visible = _is_visible


func can_interact() -> bool:
	return not _is_open


func interact(_player: Player) -> void:
	if not can_interact(): return
	sprite_2d.frame = 1
	sound.play()
	_is_open = true
	if not item == null:
		spawn_item()


func spawn_item() -> void:
	var item_sprite = Sprite2D.new()
	add_child(item_sprite)
	item_sprite.texture = item.static_texture
	item_sprite.global_position = global_position
	print("Chest positons: %v(Global Position) %v(Position)" % [global_position, position])
	print("sprite positons: %v(Global Position) %v(Position)" % [item_sprite.global_position, item_sprite.position])
	
	var tween = create_tween()
	tween.tween_property(item_sprite, "global_position", item_end_position, 0.5)
	tween.tween_callback(func(): 
		item_sprite.queue_free()
		ItemEventBus.emit_item_picked_up(item)
		).set_delay(1)


func on_triggered() -> void:
	_is_visible = true
	visible = _is_visible
	SoundEffectsPlayer.play_mystery_sound()
