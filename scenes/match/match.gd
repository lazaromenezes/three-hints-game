extends Control

var hints: Array[String] = ["Céu", "Fenômeno", "Dia vira noite"]
var hint_scene: PackedScene = preload("res://scenes/hint/hint.tscn")

const TOTAL_POINTS = 10
var _next_hint = 0

func _show_hint():
	var hint = hint_scene.instantiate()
	hint.points = TOTAL_POINTS - _next_hint
	hint.hint = hints[_next_hint]
	hint.hint_expired.connect(_on_hint_expired)
	$Hints.add_child(hint)
	
func _on_hint_expired():
	if _next_hint == 2:
		pass
	else:
		_next_hint += 1
		_show_hint()

func _on_start_timeout() -> void:
	_show_hint()
