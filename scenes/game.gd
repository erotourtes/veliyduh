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
@onready var woble: ColorRect = $main_player/Control/woble

@onready var scoreLabel: Label = score.get_tree().get_first_node_in_group("score_label")
@onready var timeLabel: Label = score.get_tree().get_first_node_in_group("time_label")
@onready var retryButton: Button = score.get_tree().get_first_node_in_group("retry_button")

@onready var die_from_poison_timer: Timer = $main_player/DieFromPoisonTimer
@onready var poison_timer: Timer = $main_player/PoisonTimer
@onready var main_player: MainPlayer = $main_player


var gameResult = EndResult.new()

func _ready() -> void:
	#sAudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	timer.endTime = 1 * 60
	timer.stopped = false
	
	background.volume_db = -60
	background.play()
	var tween = get_tree().create_tween()
	tween.tween_property(background, "volume_db", -20, 2.0)
	background.play()
	
	die_from_poison_timer.timeout.connect(main_player.take_damage)
	
	
func handle_game_over() -> void:
	hide_poison_effect.call_deferred()
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
	
	var tweenLose := create_tween()
	tweenLose.tween_property(lose, "volume_db", linear_to_db(0.01), 0.25) # fade over 0.25s
	
	var tweenWin := create_tween()
	tweenWin.tween_property(lose, "volume_db", linear_to_db(0.01), 0.25) # fade over 0.25s
	await tweenLose.finished
	await tweenWin.finished
	
	get_tree().reload_current_scene()


func _on_main_player_died() -> void:
	var someColor = Color(0.71, 0.217, 0.242, 1.0) 
	timeLabel.label_settings.font_color = someColor
	
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(lose, "volume_db", linear_to_db(0.3), 2.0).from(linear_to_db(0.001))
	lose.play()
	
	handle_game_over()

func _on_timer_ended() -> void:
	var someColor = Color(0.983, 0.818, 1.0, 1.0) 
	timeLabel.label_settings.font_color = someColor
	win.play()
	handle_game_over()
	
	


var current_wobble := 0.0
const MAX_WOBBLE := 0.1 
const WOBBLE_STEP := 0.001
var wobble_tween: Tween = null

func hide_poison_effect():
	var mat := woble.material
	if wobble_tween != null:
		wobble_tween.kill()
	wobble_tween = get_tree().create_tween()
	wobble_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	wobble_tween.tween_property(mat, "shader_parameter/wobble_strength", 0.0, 0.3)
	wobble_tween.tween_property(mat, "shader_parameter/tint_alpha", 0.0, 0.3)
	await wobble_tween.finished
	
	woble.visible = false

func show_poison_effect():
	var mat := woble.material
	if wobble_tween != null:
		wobble_tween.kill()
	wobble_tween = get_tree().create_tween()
	wobble_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	wobble_tween.tween_property(mat, "shader_parameter/wobble_strength", current_wobble, 0.03)
	wobble_tween.tween_property(mat, "shader_parameter/tint_alpha", 0.2, 0.3)
	woble.visible = true
	
func _on_main_player_poisoned_signal() -> void:
	current_wobble += WOBBLE_STEP
	if current_wobble > MAX_WOBBLE:
		current_wobble = MAX_WOBBLE
		die_from_poison_timer.start(2)
		
		
	poison_timer.start(2)
	show_poison_effect()


func _on_poison_timer_timeout() -> void:
	hide_poison_effect()
