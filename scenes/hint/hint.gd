extends Control

signal hint_expired()

@export var hint_time: float = 20

@export var points: int = 10: 
	set(value):
		points = value
		%Points.text = str(value)

@export var hint: String:
	set(value):
		hint = value
		%HintText.text = value

func _ready() -> void:
	$Timer.wait_time = hint_time
	$Timer.start()

func _process(_delta: float) -> void:
	%Progress.value = $Timer.time_left / hint_time

func _on_timer_timeout() -> void:
	hint_expired.emit()
