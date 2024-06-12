extends Control

var word: Word = preload("res://scenes/word/chuva.tres")
var hint_scene: PackedScene = preload("res://scenes/hint/hint.tscn")

const TOTAL_POINTS: int = 10

var _current_points: int = TOTAL_POINTS
var _hints: Array[String] = []

func _ready() -> void:
	$StartTimer.start(GameManager.settings.start_time)
	_hints = word.hints

func _show_hint():
	var hint = hint_scene.instantiate()
	hint.hint = _hints.pop_front()
	hint.hint_expired.connect(_on_hint_expired)
	%Hints.add_child(hint)
	
func _on_hint_expired():
	if _hints.size() > 0:
		_current_points -= 1
		_next_hint()

func _on_start_timeout() -> void:
	_next_hint()
	
func _next_hint() -> void:
	%Points.text = str(_current_points)
	_show_hint()
