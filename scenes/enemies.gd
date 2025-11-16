extends Node

@onready var positions_container: Node = $positions_container
@onready var enemies_container: Node = $enemies_container

@export var enemy_scene: PackedScene           # assign your Enemy.tscn
@export var spawn_interval := 2.0              # seconds between spawns
@export var max_enemies := 5                   # total alive at once
@export var enemy_lifetime := 8.0              # auto-despawn time

signal score(score: int)

var scoreCounter := 0:
	set(value):
		scoreCounter = value
		score.emit(value)


var positions: Array[Marker2D] = []
var free_positions: Array[Marker2D] = []
var occupied_positions := {}   # enemy -> marker

var timer := spawn_interval

func _ready():
	# collect all Marker2D nodes inside container
	for child in positions_container.get_children():
		if child is Marker2D:
			positions.append(child)
			free_positions.append(child)

func _process(delta):
	timer += delta
	
	if timer >= spawn_interval:
		timer = 0
		maybe_spawn()

func maybe_spawn():
	# cleanup()

	if enemies_container.get_child_count() >= max_enemies:
		return
	if free_positions.is_empty():
		return

	spawn_enemy()

func spawn_enemy():
	var pos: Marker2D = free_positions.pick_random()

	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos.global_position
	enemies_container.add_child(enemy)

	# assign lifetime & signal
	# enemy.set_lifetime(enemy_lifetime)
	enemy.died.connect(_on_enemy_died)

	# lock this position
	free_positions.erase(pos)
	occupied_positions[enemy] = pos
	
	await get_tree().create_timer(enemy_lifetime).timeout
	handle_remove_enemy(enemy)
	if enemy != null and not enemy.is_queued_for_deletion():
		enemy.queue_free()

func handle_remove_enemy(enemy):
	if occupied_positions.has(enemy):
		var pos = occupied_positions[enemy]
		occupied_positions.erase(enemy)
		await get_tree().create_timer(1.0).timeout
		free_positions.append(pos)

func _on_enemy_died(enemy):
	handle_remove_enemy(enemy)
	scoreCounter += 1
	
		

#func cleanup():
	## If enemies disappeared for any reason (queue_free outside die)
	#for enemy in occupied_positions.keys():
		#if not enemy.is_inside_tree():
			#var pos = occupied_positions[enemy]
			#free_positions.append(pos)
			#occupied_positions.erase(enemy)
