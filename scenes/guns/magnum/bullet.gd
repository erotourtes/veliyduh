extends Area2D

var direction: Vector2 = Vector2(1.0, 0.0)
var speed := 2000 * Globals.PIXEL_MULTIPILER
var lifeSpan := 3
var timer := 0.0

func _ready():
	pass
	# velocity.x = direction.x * speed

func _physics_process(delta):
	timer += delta
	if (timer > lifeSpan):
		queue_free()
		return
		
	position.x += delta * speed * direction.x
	position.y += delta * speed * direction.y


func _on_body_entered(body: Node2D) -> void:
	print(body)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage()
	queue_free()
