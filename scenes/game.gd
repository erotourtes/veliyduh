extends Node2D

class EndResult:
	var score := 0
	var isDied := false

@onready var lose: AudioStreamPlayer = $audio/lose
@onready var win: AudioStreamPlayer = $audio/win
@onready var timer: Label = $main_player/timer
@onready var background: AudioStreamPlayer = $audio/background

@onready var control: Control = $main_player/Control
@onready var smoke: ColorRect = $main_player/Control/smoke
@onready var score: Control = $main_player/Control/score
@onready var blur: ColorRect = $main_player/Control/blur

@onready var scoreLabel: Label = score.get_tree().get_first_node_in_group("score_label")
@onready var timeLabel: Label = score.get_tree().get_first_node_in_group("time_label")
@onready var retryButton: Button = score.get_tree().get_first_node_in_group("retry_button")


var gameResult = EndResult.new()

func _ready() -> void:
	timer.endTime = 1 * 60
	timer.stopped = false
	
	background.volume_db = -60
	background.play()
	var tween = get_tree().create_tween()
	tween.tween_property(background, "volume_db", -20, 2.0)
	background.play()
	
func handle_game_over() -> void:
	background.stop()
	get_tree().paused = true
		
	smoke.visible = false
	blur.visible = true
	
	control.visible = true
	score.visible = true
	
		
	scoreLabel.text = "Score: " + str(gameResult.score)
	timeLabel.text = timer.time_to_string()
	
	retryButton.pressed.connect(_on_retry_button_pressed)
	
	
func _on_enemies_score(score: int) -> void:
	gameResult.score = score	
	
func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_player_died() -> void:
	var someColor = Color(0.71, 0.217, 0.242, 1.0) 
	timeLabel.label_settings.font_color = someColor
	lose.play()
	handle_game_over()

func _on_timer_ended() -> void:
	var someColor = Color(0.983, 0.818, 1.0, 1.0) 
	timeLabel.label_settings.font_color = someColor
	win.play()
	handle_game_over()
