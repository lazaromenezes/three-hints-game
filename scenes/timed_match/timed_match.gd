extends Control

@onready var offline_word_provider: OfflineWordProvider = $OfflineWordProvider

var _match_words: Array[Word]
var _word_scene: PackedScene = preload("res://scenes/word/word.tscn")

var _total_points: int = 0:
	set(value):
		%Points.text = str(value)
		_total_points = value

func _ready() -> void:
	$StartTimer.start(GameManager.settings.match_start_time)
	_match_words = offline_word_provider.take_random(GameManager.settings.words_per_match)

func _on_start_timer_timeout() -> void:
	_next_word()

func _next_word():
	if not _match_words.is_empty():
		if %WordContainer.get_child_count() > 0:
			await _clear_container()
			
		var word = _pop_random_word()
		_add_word_scene(word)
	else:
		get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")

func _clear_container():
	var word_scene = %WordContainer.get_child(0)
	word_scene.queue_free()
	await word_scene.tree_exited

func _pop_random_word():
	_match_words.shuffle()
	return _match_words.pop_back()

func _add_word_scene(word: Word):
	var word_scene = _word_scene.instantiate()
	word_scene.word = word
	word_scene.timed_up.connect(_on_word_timed_up)
	word_scene.guessed_right.connect(_on_word_guessed_correctly)
	%WordContainer.add_child(word_scene)

func _on_word_timed_up():
	_next_word()

func _on_word_guessed_correctly(points: int):
	_total_points += points
	_next_word()
