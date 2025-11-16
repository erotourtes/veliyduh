class_name Enemy
extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var vision: RayCast2D = $vision
@onready var killzone: Area2D = $killzone

var is_dead := false
var inFov := false
var player: Node2D = null

signal died(Enemy)

func take_damage():
	die()
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not inFov:
		return
	vision.target_position = player.global_position - global_position
	vision.target_position.x += 500
	if not vision.is_colliding():
		return
	player.poison()
	

func die():
	if is_dead:
		return
	is_dead = true
	visible = false
	remove_child(killzone)

	
	audio_stream_player.play()
	died.emit(self)
	await  audio_stream_player.finished
	queue_free()
	
	
func _on_pov_body_entered(body: Node2D) -> void:
	print("body entered", body.get_class())
	if not body.has_method("poison"):
		return
	inFov = true
	player = body
	
func _on_pov_body_exited(body: Node2D) -> void:
	print("body removed", body.get_class())
	if not body.has_method("poison"):
		return
	inFov = false
