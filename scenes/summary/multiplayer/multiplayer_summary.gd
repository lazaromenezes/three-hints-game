extends Control

var rank_entry: PackedScene = preload("res://scenes/rank_entry/rank_entry.tscn")

func _ready():
	if MultiplayerGameManager.session:
		MultiplayerGameManager.player_finished.connect(_on_player_finished)
		MultiplayerGameManager.finish()

func _on_main_menu_pressed() -> void:
	SceneManager.transition_to("home")

func _on_player_finished():
	%RankList.get_children().all(func (c): c.queue_free())
	
	_update_rank.call_deferred()

func _update_rank():
	var rank_position = 1
	
	for ranked_player in MultiplayerGameManager.rank:
		var entry = rank_entry.instantiate()
		entry.enter_data(rank_position, ranked_player)
		%RankList.add_child(entry)
		
		rank_position += 1
