extends Control


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Start.tscn")


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Game.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
