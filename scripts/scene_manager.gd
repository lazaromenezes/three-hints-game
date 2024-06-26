extends Node

var _screens: Dictionary = {
	"home": preload("res://scenes/home_screen/home_screen.tscn"),
	"solo": preload("res://scenes/timed_match/timed_match.tscn"),
	"summary": preload("res://scenes/summary/solo/solo_summary.tscn"),
	"lobby": preload("res://scenes/lobby/lobby.tscn"),
	"multiplayer": preload("res://scenes/multiplayer_match/multiplayer_match.tscn"),
	"multiplayer-summary": preload("res://scenes/summary/multiplayer/multiplayer_summary.tscn")
}

func load_scenes() -> void:
	for screen in _screens.keys():
		ResourceLoader.load_threaded_request(_screens[screen], "", true)
		
func report_status() -> float:
	var overall_status: Array = []
	var load_status: Array = []
	
	for screen in _screens.keys():
		ResourceLoader.load_threaded_get_status(_screens[screen], load_status)
		overall_status.push_back(load_status[0])
		
	return overall_status.reduce(func(a, b): return a + b, 0) / overall_status.size()

func transition_to(key: String) -> void:
	get_tree().change_scene_to_packed(_screens[key])
