extends Node2D
class_name WeaponBase

var player: MainPlayer



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
	
func setup() -> Node:
	assert(false, "Should impllement setup method")
	return null
	
func desintegrate():
	queue_free()
