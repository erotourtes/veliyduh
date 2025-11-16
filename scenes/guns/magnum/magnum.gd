class_name Magnum
extends WeaponBase

const SCENE = preload("uid://b5b6db7p2220i")

const HAND_ALIGNMENT = Vector2(
	-20,
	20,
)

const RECOIL_FORCE = Vector2(
	-350*Globals.PIXEL_MULTIPILER, 
	-250*Globals.PIXEL_MULTIPILER
)

func setup() -> Node:
	var scene = SCENE.instantiate()
	return scene
	
func get_hand_alighnemnt() -> Vector2:
	return HAND_ALIGNMENT

func start_firing():
	var recoilForce = Vector2(RECOIL_FORCE)
	recoilForce.x *= player.playerDirection
	player.recoilForce = recoilForce
