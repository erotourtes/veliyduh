extends Node2D

class EndResult:
	var score := 0
	var isDied := false

@onready var lose: AudioStreamPlayer = $audio/lose
@onready var win: AudioStreamPlayer = $audio/win
@onready var timer: Label = $main_player/timer

@onready var control: Control = $main_player/Control
@onready var smoke: ColorRect = $main_player/Control/smoke
@onready var score: Control = $main_player/Control/score
@onready var blur: ColorRect = $main_player/Control/blur

var gameResult = EndResult.new()

func _ready() -> void:
	timer.endTime = 1 * 3
	timer.stopped = false
	
func handle_game_over() -> void:
	get_tree().paused = true
		
	smoke.visible = false
	blur.visible = true
	
	control.visible = true
	score.visible = true
	
	var scoreLabel: Label = score.get_tree().get_first_node_in_group("score_label")
	var time: Label = score.get_tree().get_first_node_in_group("time_label")
	var retryButton: Button = score.get_tree().get_first_node_in_group("retry_button")
	
	scoreLabel.text = "Score: " + str(gameResult.score)
	time.text = timer.time_to_string()
	retryButton.pressed.connect(_on_retry_button_pressed)
	

func _on_timer_ended() -> void:
	win.play()
	handle_game_over()
	await win.finished
	
func _on_enemies_score(score: int) -> void:
	gameResult.score = score
	
	
func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
