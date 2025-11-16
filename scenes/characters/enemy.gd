class_name Enemy
extends Node2D

var is_dead := false

signal died(Enemy)

func take_damage():
	die()

func die():
	is_dead = true
	died.emit(self)
	queue_free()
