extends Label

@onready var timer: Label = $"."

var time := 0.0
var stopped := true
@export var endTime := 1 * 60

signal ended;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stopped:
		return
	
	time += delta
	timer.text = time_to_string()
	
	if time >= endTime:
		stopped = true
		ended.emit()
	
	
func reset():
	time = 0.0
	
	
func time_to_string() -> String:
	var msec = fmod(time, 1) * 1000
	var sec = fmod(time, 60)
	var minutes = time / 60
	var format = "%02d : %02d : %03d"
	var formatted = format % [minutes, sec, msec]
	return formatted
