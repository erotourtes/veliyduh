class_name Enemy
extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var vision: RayCast2D = $vision
@onready var killzone: Area2D = $killzone
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
		animation_player.stop()
		return
	vision.target_position = vision.to_local(player.global_position)
	vision.force_raycast_update()
	
	if not vision.is_colliding() or vision.get_collider() != player:
		return
	player.poison()
	animation_player.play("active")
	

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
		inFov = false
		return
	inFov = true
	player = body
	
func _on_pov_body_exited(body: Node2D) -> void:
	print("body removed", body.get_class())
	if body != player:
		return
	inFov = false
