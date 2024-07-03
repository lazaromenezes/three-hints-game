extends Control

signal timed_up(used_time: float)
signal guessed_right(points: int, used_time: float)

@export var word: Word

var hint_scene: PackedScene = preload("res://scenes/hint/hint.tscn")
const TOTAL_POINTS: int = 10

var _current_points: int = TOTAL_POINTS
var _total_time: float = 0
var _hints: Array[String] = []

func _ready() -> void:
	$StartTimer.start(ConfigurationProvider.settings.word_start_time)
	_hints = word.hints

func _process(delta: float) -> void:
	_total_time += delta

func _show_hint():
	var hint = hint_scene.instantiate()
	hint.hint = _hints.pop_front()
	hint.timed_up.connect(_on_hint_expired)
	%Hints.add_child(hint)
	
func _on_hint_expired():
	if _hints.size() > 0:
		_current_points -= 1
		_next_hint()
	else:
		timed_up.emit(_total_time)

func _on_start_timeout() -> void:
	%GuessArea.show()
	_next_hint()

func _next_hint() -> void:
	%Points.text = str(_current_points)
	_show_hint()

func _on_guess_area_guessed(guess: String) -> void:
	if guess in word.cleaned_accepted_answers:
		guessed_right.emit(_current_points, _total_time)
