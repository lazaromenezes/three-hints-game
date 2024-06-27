extends Node

var _screens: Dictionary = {
	"home": preload("res://scenes/home_screen/home_screen.tscn"),
	"solo": preload("res://scenes/timed_match/timed_match.tscn"),
	"summary": preload("res://scenes/summary/solo/solo_summary.tscn"),
	"lobby": preload("res://scenes/lobby/lobby.tscn"),
	"multiplayer": preload("res://scenes/multiplayer_match/multiplayer_match.tscn"),
	"multiplayer-summary": preload("res://scenes/summary/multiplayer/multiplayer_summary.tscn")
}

func transition_to(key: String) -> void:
	get_tree().change_scene_to_packed(_screens[key])
