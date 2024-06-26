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
	var rank = 1
	for session in MultiplayerGameManager.rank_finished_players():
		var entry = rank_entry.instantiate()
		
		entry.enter_data(rank, session)
		
		%RankList.add_child(entry)
		
		rank += 1
