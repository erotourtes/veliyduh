extends Area2D

@onready var enemy: Node2D = $".."

	
func take_damage():
	enemy.take_damage();
	
