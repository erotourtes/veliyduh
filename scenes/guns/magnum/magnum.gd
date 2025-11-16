class_name Magnum
extends WeaponBase

const SCENE = preload("uid://b5b6db7p2220i")
const BULLET = preload("uid://bagu25ev6jwes")

@onready var muzzle: Marker2D = $muzzle

var isFiring := false

const HAND_ALIGNMENT = Vector2(
	-20,
	20,
)

const RECOIL_FORCE = Vector2(
	-350*Globals.PIXEL_MULTIPILER, 
	-250*Globals.PIXEL_MULTIPILER
)

func setup(bulletContainer: Node) -> void:
	self.bulletContainer = bulletContainer

	
func get_hand_alighnemnt() -> Vector2:
	return HAND_ALIGNMENT

func start_firing():
	isFiring = true
	var recoilForce = Vector2(RECOIL_FORCE)
	recoilForce.x *= player.playerDirection	
	player.recoilForce = recoilForce
	
	var bullet = BULLET.instantiate()
	bulletContainer.add_child(bullet)
	bullet.global_position = muzzle.global_position
	
	var dirVec = Vector2(cos(self.rotation) * player.playerDirection, sin(self.rotation))
	if (player.playerDirection < 0):
		bullet.scale.x = -1
	bullet.direction = dirVec
	
	
	stop_firing()

func stop_firing():
	isFiring = false
	
