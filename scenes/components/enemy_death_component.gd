class_name EnemyExplosion extends AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



func _on_timer_timeout() -> void:
	audio_stream_player.stop()
	queue_free()
