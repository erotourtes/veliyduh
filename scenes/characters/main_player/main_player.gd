class_name MainPlayer extends CharacterBody2D

var PIXEL_MULTIPILER: int = Globals.PIXEL_MULTIPILER

var SPEED := 212 * PIXEL_MULTIPILER
var JUMP_VELOCITY := -225 * PIXEL_MULTIPILER

@export var bulletContainer: Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $visuals
@onready var hand_anchor: Node2D = $visuals/hand_anchor

@onready var weaponNode: Node2D = $visuals/hand_anchor/Weapon


var isFlying := false
var weapon: WeaponBase = null
var playerDirection = 1

var recoilForce: Vector2 = Vector2.ZERO

@export var hoveringVelocity := 150 * PIXEL_MULTIPILER

func _ready() -> void:
	animation_player.play("idle_body_idle_hand")
	
var direction := 0.0
var isMovingLeft := false
var isMovingRight := false
var isStill := true

var isJumpingUp := false
var isJumpingDown := false
var isWalking := false
var isSitting := false

func _physics_process(delta: float) -> void:
	var isDownPressed = Input.is_action_pressed("down")
	
	direction = Input.get_axis("left", "right")
	
	isMovingLeft = direction == -1
	isMovingRight = direction == 1
	isStill = direction == 0
	
	isJumpingUp = velocity.y < 0 and !is_on_floor() and !isFlying
	isJumpingDown = velocity.y > 0 and !is_on_floor() and !isFlying
	isWalking = !isStill and is_on_floor()
	isSitting = isStill and isDownPressed
	
	handle_jump(delta)	
	
	if isDownPressed:
		isFlying = false
	
	handleVelocityChange(delta)
	
	if isMovingLeft:
		playerDirection = -1
		visuals.scale.x = -1
	if isMovingRight:
		playerDirection = 1
		visuals.scale.x = 1

	
	updatePlayerAnimation()

	move_and_slide()



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		handleFire()
	if event.is_action_pressed("pick"):
		handlePick()
	if event.is_action_released("fire"):
		if weapon != null:
			weapon.stop_firing()
	

func handleFire():
	if (weapon == null):
		return
	
	weapon.start_firing()
	
func take_damage():
	print("damage taken")	
	
func handlePick():
	if weapon != null:
		for child in weaponNode.get_children():
			weaponNode.remove_child(child)
			
		weapon.desintegrate()
		weapon = null
		return
	
	var scene = Magnum.SCENE.instantiate()
	weapon = scene as WeaponBase
	weapon.setup(bulletContainer)
	scene.position = weapon.get_hand_alighnemnt()
	weaponNode.add_child(scene)
	
	weapon.pick(self)
	


const MAX_JUMP_TIME := 0.30
const JUMP_SOFTNESS = 1.0
var jumpPressedTime := 0.0
var isHandlingSoftJumping := false
var isAbleToFly := false
var isAllowedToFlyOnNextTick := false
var isJumpStarted := false


func handle_jump(delta: float):	
	if is_on_floor():
		isFlying = false
		isAbleToFly = false
		isJumpStarted = false
	
	var isFallingDownWithoutJump := not is_on_floor() and velocity.y >= 0 and not isJumpStarted
	if isFallingDownWithoutJump:
		isAbleToFly = true
		isAllowedToFlyOnNextTick = true
	
	var shouldStartJump := Input.is_action_just_pressed("jump") and is_on_floor()
	if shouldStartJump:
		velocity.y = JUMP_VELOCITY
		jumpPressedTime = 0.0
		isHandlingSoftJumping = true
		isAbleToFly = true
		isAllowedToFlyOnNextTick = false
		isFlying = false
		isJumpStarted = true

	var shouldProlongJump := isHandlingSoftJumping and Input.is_action_pressed("jump")
	if shouldProlongJump:
		jumpPressedTime += delta
		if jumpPressedTime < MAX_JUMP_TIME:
			velocity.y = JUMP_VELOCITY * JUMP_SOFTNESS
	
	var isJustReleasedJump := Input.is_action_just_released("jump")
	if isJustReleasedJump:
		isAllowedToFlyOnNextTick = true
		
	var shouldReleaseJump := isJustReleasedJump or jumpPressedTime >= MAX_JUMP_TIME
	if shouldReleaseJump:
		isHandlingSoftJumping = false
	
	var shouldStartFlying := Input.is_action_pressed("jump") and not is_on_floor() and not isHandlingSoftJumping and isAllowedToFlyOnNextTick
	if shouldStartFlying and isAbleToFly:
		isFlying = true
	else:
		isFlying = false
		

func updatePlayerAnimation() -> void:
	var handType = "idle"
	if weapon != null:
		handType = "active"
		
	if isWalking:
		animation_player.play("walking_body_" + handType + "_hand")
	elif isJumpingUp:
		animation_player.play("jumping_up_body_" + handType + "_hand")
	elif isJumpingDown:
		animation_player.play("jumping_down_body_" + handType + "_hand")
	elif isSitting:
		animation_player.play("sitting_body_" + handType + "_hand")
	elif isFlying:
		animation_player.play("flying_body_" + handType + "_hand")
	else: 
		animation_player.play("idle_body_" + handType + "_hand")
	
	




var movingUpTimer: float = 0.0
const RECOIL_DURATION: float = 1

func handleVelocityChange(delta: float) -> void:
	var gravity := get_gravity().y
	
	if is_on_floor():
		movingUpTimer = 0
	if movingUpTimer < RECOIL_DURATION:
		movingUpTimer = min(movingUpTimer + delta, RECOIL_DURATION)
	
	if velocity.y > 0:
		recoilForce.y = 0

	if velocity.y <= 0:
		var timeWeight := (RECOIL_DURATION - movingUpTimer) / RECOIL_DURATION
		var jumpWieght: float = clamp((velocity.y / JUMP_VELOCITY), 0.0, 1.0)
		if is_on_floor():
			jumpWieght = 0.3
		var weight = timeWeight * jumpWieght
		
		var boost: float = lerp(recoilForce.y, 0.0, 1 - weight)
		# print(timeWeight, " ", jumpWieght, " ", weight, " ", boost)
		velocity.y += boost
		velocity.y = clamp(velocity.y, -abs(JUMP_VELOCITY) * 1, 0.0)


	if isFlying:
		var shouldSoftenStrongFall := velocity.y > 300
		if shouldSoftenStrongFall:
			velocity.y = 300

		var shouldHaveLift := velocity.y < 0
		if shouldHaveLift:
			velocity.y -= 200 * delta

		velocity.y += gravity * 0.3 * delta
		velocity.y = clamp(velocity.y, -200, 600*PIXEL_MULTIPILER)

	elif not is_on_floor():
		var gravityHop := 1.0
		if velocity.y < 30 * PIXEL_MULTIPILER:
			gravityHop = 0.4

		velocity.y += gravity * gravityHop * delta

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var recoilXmultpilier = 1.0
	if not is_on_floor():
		recoilXmultpilier = 2.0
	velocity.x += clamp(recoilForce.x * recoilXmultpilier, -SPEED * 5, SPEED * 5)
	
	
	recoilForce = recoilForce.lerp(Vector2.ZERO, 0.6)
	# recoilForce = Vector2.ZERO
