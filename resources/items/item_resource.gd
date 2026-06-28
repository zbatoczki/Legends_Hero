class_name ItemResource extends Resource

var stacks := 1

@export var name: String
## Optional. Will override animated texture if provedied, required if animated texture not provided
@export var static_texture: Texture2D
## Optional. Will override static texture if provedied, required if static texture not provided
@export var animated_texture: SpriteFrames
@export var collision_shape: Shape2D
@export var sound_effect: AudioStream
@export var max_stacks: int
@export var price: int
@export var equipable: bool = false
@export var in_hud: bool = false
## Optional. The action performed when this item is equipped to slot A or B.
@export var action: ActionResource
