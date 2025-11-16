extends CharacterBody2D
class_name WeaponBase

var player: MainPlayer
var bulletContainer: Node
var is_active: bool = false # To control if it processes physics
@export var throw_speed: float = 3200.0
@export var throw_initial_up_force: float = 1200.0
@export var despawn_time_after_throw: float = 5.0

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

func _physics_process(delta: float):
	if not is_active:
		return # Only process if active

	# Apply gravity
	velocity.y += 12000.0 * delta
	

	velocity.x -= sign(velocity.x) * lerp(0.0, abs(velocity.x), 0.4) * delta

	# Move and slide
	move_and_slide()

	# Optional: Rotate the gun visually while thrown
	# if velocity.length_squared() > 10.0:
	#     rotation += sign(velocity.x) * 0.1 * delta * 60.0
	
func activate_physics_for_throw(initial_direction: Vector2, additional_velocity: Vector2):
	is_active = true
	set_physics_process(true)
	velocity = initial_direction.normalized() * throw_speed
	velocity += additional_velocity
	velocity.y -= throw_initial_up_force # Add an upward arc
	
	get_tree().create_timer(despawn_time_after_throw).timeout.connect(desintegrate)
