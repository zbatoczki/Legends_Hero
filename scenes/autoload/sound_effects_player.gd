extends Node

@onready var damage_sound: AudioStreamPlayer = $DamageSound
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound
@onready var item_sound: AudioStreamPlayer = $ItemSound
@onready var mystery_sound: AudioStreamPlayer = $MysterySound
@onready var boss_damage_sound: AudioStreamPlayer = $BossDamageSound
@onready var boss_music: AudioStreamPlayer = $BossMusic
@onready var dungeon_music: AudioStreamPlayer = $DungeonMusic

func play_damaged_sound(is_boss: bool = false) -> void:
	if is_boss:
		boss_damage_sound.play()
	else:
		damage_sound.play()


func play_game_over_sound() -> void:
	game_over_sound.play()


func play_item_sound(audio: AudioStream = null) -> void:
	if audio == null: return
	item_sound.stream = audio
	item_sound.play()

func play_mystery_sound() -> void:
	mystery_sound.play()


func play_boss_music() -> void:
	dungeon_music.stop()
	boss_music.play()
