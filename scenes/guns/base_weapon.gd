extends CharacterBody2D
class_name WeaponBase

var player: MainPlayer
var bulletContainer: Node


func pick(player):
	self.player = player

func start_firing():
	assert(false, "Should impllement setup method")

func stop_firing():
	pass

func weapon_update(delta):
	pass
	
func get_hand_alighnemnt() -> Vector2:
	return Vector2.ZERO
	
func setup(bulletContainer: Node) -> void:
	assert(false, "Should impllement setup method")

func desintegrate():
	queue_free()
