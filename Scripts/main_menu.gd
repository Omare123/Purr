class_name MainMenu extends Control
@onready var start_button = $MarginContainer/VBoxContainer/Start_Button
@onready var quit_button = $MarginContainer/VBoxContainer/Quit_Button
@onready var main_level = preload("res://Scenes/game.tscn")

func _on_start_button_button_down():
	get_tree().change_scene_to_packed(main_level)

func _on_quit_button_button_down():
	get_tree().quit()
