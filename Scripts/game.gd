extends Node2D
const NPC_SCENE = preload("res://Scenes/Characters/npc.tscn")
const PAUSE_MENU = preload("res://Scenes/others/pause_menu.tscn")
const GAME_OVER_MENU = preload("res://Scenes/others/game_over_menu.tscn")

@export var npc_to_add = 10
@export var limit_up_left = Vector2(5,5)
@export var limit_down_right = Vector2(1690,1125)
@onready var cat = $Cat
@onready var tile_map: TileMap = $TileMap
@onready var timer = $CanvasLayer/Time
@onready var cat_people_counter = $"CanvasLayer/Cat People Counter"

const PAUSE = "pause"
const sprites_path = "res://Assets/Sprites/"
const NPC_NAMES = "res://Resources/npc_sprite_names.json"
const npc_max_nbr = 7
var time: float = 0
var is_timer_active := false
var counter = 0
func _ready():
	start()
	var json_as_text = FileAccess.get_file_as_string(NPC_NAMES)
	var json_as_dict = JSON.parse_string(json_as_text)["data"]
	for n in npc_to_add:
		randomize()
		var i = randi_range(0, npc_max_nbr)
		var npc = NPC_SCENE.instantiate()
		var npc_resource = NPCResource.new()
		var img = Image.new()
		var tex = ImageTexture.new()
		img.load(sprites_path + json_as_dict[i])
		npc_resource.texture = tex.create_from_image(img)
		var npc_position = get_random_position()
		npc.npc_resource = npc_resource
		npc.player = cat
		npc.position = npc_position
		add_child(npc)

func _input(event):
	if event.is_action_pressed(PAUSE):
		var pause_screen := PAUSE_MENU.instantiate()
		add_child.call_deferred(pause_screen)

func get_random_position():
	var recalculate = true 
	var final_position = Vector2.ZERO
	while recalculate:
		randomize()
		var x_position = randi_range(limit_up_left.x, limit_down_right.x)
		var y_position = randi_range(limit_down_right.y, limit_up_left.y)
		final_position = Vector2(x_position, y_position)
		var posible_position = tile_map.local_to_map(final_position)
		#this gets if is a obstacle to re-roll
		var tile = tile_map.get_cell_tile_data(1, posible_position)
		if tile == null:
			recalculate = false
		
	return final_position

func reset():
	time = 0

func start():
	is_timer_active = true

func stop():
	is_timer_active = false
	
func game_over():
	var game_over_screen := GAME_OVER_MENU.instantiate()
	add_child.call_deferred(game_over_screen)
	game_over_screen.set_time(timer.text)

func _process(delta):
	timer.text = get_time(delta)
	
func get_time(delta):
	if(!is_timer_active):
		pass
	time += delta
	var seconds = fmod(time,60)
	var minutes = fmod(time, 60*60) / 60
	return "%02d:%02d" % [minutes, seconds]

func _on_cat_got_person_in_love():
	counter += 1
	cat_people_counter.text = str(counter)
	if counter == npc_to_add:
		game_over()
