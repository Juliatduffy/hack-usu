extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/HowTo.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
