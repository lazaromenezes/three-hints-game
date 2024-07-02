extends Node
class_name OnlineWordProvider

signal words_loaded()

@onready var http_request: HTTPRequest = $HTTPRequest
var settings: GameSettings
var _words: Array[Word]

func _ready() -> void:
	_words = []
	http_request.request_completed.connect(_on_request_completed)

func take_random(amount: int) -> Array[Word]:
	var url = settings.words_endpoint % amount
	
	http_request.request(url)
	
	await words_loaded
	
	return _words as Array[Word]

func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var words_data := body.get_string_from_utf8()
	var loaded_words = JSON.parse_string(words_data)
	
	_words.clear()
	
	for w in loaded_words:
		_words.push_back(Word.from_dict(w))
	
	words_loaded.emit()
