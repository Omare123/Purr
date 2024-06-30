class_name MainMenu extends Control
@onready var main_level = preload("res://Scenes/game.tscn")
@onready var controls = $Controls
@onready var main = $Main
@onready var back_button = $Back

func _on_start_button_button_down():
	get_tree().change_scene_to_packed(main_level)

func _on_quit_button_button_down():
	get_tree().quit()

func _on_controls_button_down():
	main.visible = false
	controls.visible = true
	back_button.visible = true

func _on_back_button_down():
	main.visible = true
	controls.visible = false
	back_button.visible = false
