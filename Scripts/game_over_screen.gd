extends CanvasLayer
@onready var pause_ui = $Control
@onready var back = $Back
@onready var instructions = $Instructions
var pause = true
func _ready():
	get_tree().paused = pause

func _on_restart_button_down():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func _on_quit_button_down():
	get_tree().quit()
	

func _on_resume_button_down():
	get_tree().paused = false
	queue_free()

func _on_back_button_down():
	pause_ui.visible = true
	back.visible = false
	instructions.visible = false

func _on_instructions_button_down():
	pause_ui.visible = false
	back.visible = true
	instructions.visible = true
