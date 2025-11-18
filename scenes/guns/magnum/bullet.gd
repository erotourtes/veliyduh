extends CharacterBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D

var direction: Vector2 = Vector2(1.0, 0.0)
var speed := 2000 * Globals.PIXEL_MULTIPILER
var lifeSpan := 3
var timer := 0.0
var alive := true

func _ready():
	velocity.x = speed * direction.x

func _physics_process(delta):
	if not alive:
		sprite_2d.visible = false
		return
		
		
	timer += delta
	if (timer > lifeSpan):
		alive = false
		queue_free()
		return

	var colided := move_and_slide()
	if colided:
		alive = false
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	alive = false
	if area.has_method("take_damage"):
		area.take_damage()
	queue_free()
