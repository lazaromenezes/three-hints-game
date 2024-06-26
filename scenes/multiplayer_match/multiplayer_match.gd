extends Control

var _match_words: Array[Word]
var _word_scene: PackedScene = preload("res://scenes/word/word.tscn")

func _ready() -> void:
	$StartTimer.start(GameManager.settings.match_start_time)
	_match_words = MultiplayerGameManager.words

func _on_start_timer_timeout() -> void:
	_next_word()

func _next_word():
	if not _match_words.is_empty():
		if %WordContainer.get_child_count() > 0:
			await _clear_container()
			
		var word = _pop_random_word()
		_add_word_scene(word)
	else:
		SceneManager.transition_to("multiplayer-summary")

func _clear_container():
	var word_scene = %WordContainer.get_child(0)
	word_scene.queue_free()
	await word_scene.tree_exited

func _pop_random_word():
	_match_words.shuffle()
	return _match_words.pop_back()

func _add_word_scene(word):
	var word_scene = _word_scene.instantiate()
	word_scene.word = word
	word_scene.timed_up.connect(_on_word_timed_up)
	word_scene.guessed_right.connect(_on_word_guessed_correctly)
	%WordContainer.add_child(word_scene)

func _on_word_timed_up(used_time: float):
	MultiplayerGameManager.session.total_time += used_time
	_next_word()

func _on_word_guessed_correctly(points: int, used_time: float):
	MultiplayerGameManager.session.total_points += points
	MultiplayerGameManager.session.total_time += used_time
	%Points.text = str(MultiplayerGameManager.session.total_points)
	_next_word()
