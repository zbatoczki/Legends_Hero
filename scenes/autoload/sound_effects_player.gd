extends Node

@onready var damage_sound: AudioStreamPlayer = $DamageSound
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound

func play_damaged_sound() -> void:
	damage_sound.play()
	
func play_game_over_sound() -> void:
	game_over_sound.play()
