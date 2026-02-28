extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Game.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://HowTo.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
