extends Label

var time: float = 0
var is_timer_active := false

func reset():
	time = 0

func start():
	is_timer_active = true

func stop():
	is_timer_active = false

func _ready():
	start()

func _process(delta):
	if(!is_timer_active):
		pass
	
	time += delta
	var seconds = fmod(time,60)
	var minutes = fmod(time, 60*60) / 60
	#var hours = fmod(fmod(time,3600 * 60) / 3600,24)
	
	var time_passed = "%02d:%02d" % [minutes, seconds]
	text = time_passed
