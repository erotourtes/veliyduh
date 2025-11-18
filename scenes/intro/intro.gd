extends Control

func changeScene():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	changeScene()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		changeScene()
	
