extends CanvasLayer
@export var timer: Label

func _ready():
	get_tree().paused = true
	
func set_time(time):
	timer.text += time

func _on_restart_button_down():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func _on_quit_button_down():
	get_tree().quit()

func _on_resume_button_down():
	get_tree().paused = false
	queue_free()
