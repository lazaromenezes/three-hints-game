extends Resource
class_name GameSettings

@export var match_start_time: float
@export var word_start_time: float
@export var hint_time: float
@export var words_per_match: int
@export var is_online: bool
@export var words_endpoint: String = "http://localhost:8080/words?amount=%s"
@export var server_url: String = "localhost"
@export var server_port: int = 1609
@export var max_clients: int = 2048
