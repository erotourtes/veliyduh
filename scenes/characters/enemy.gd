class_name Enemy
extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var is_dead := false

signal died(Enemy)

func take_damage():
	die()

func die():
	is_dead = true
	audio_stream_player.play()
	died.emit(self)
	queue_free()
