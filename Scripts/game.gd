extends Node2D
const NPC_SCENE = preload("res://Scenes/Characters/npc.tscn")
const PAUSE_MENU = preload("res://Scenes/others/pause_menu.tscn")
const GAME_OVER_MENU = preload("res://Scenes/others/game_over_menu.tscn")

@export var npc_to_add = 10
@export var limit_up_left = Vector2(5,5)
@export var limit_down_right = Vector2(1690,1125)
@onready var cat = $Cat
@onready var tile_map: TileMap = $NavigationRegion2D/TileMap
@onready var visible_timer = $CanvasLayer/Time
@onready var cat_people_counter = $"CanvasLayer/Cat People Counter"
@onready var game_timer = $"Game Timer"

const PAUSE = "pause"
const sprites_path = "res://Assets/Sprites/"
const NPC_NAMES = "res://Resources/npc_sprite_names.json"
const npc_max_nbr = 7
var counter = 0
func _ready():
	var json_as_text = FileAccess.get_file_as_string(NPC_NAMES)
	var json_as_dict = JSON.parse_string(json_as_text)["data"]
	for n in npc_to_add:
		randomize()
		var i = randi_range(0, npc_max_nbr)
		var npc = NPC_SCENE.instantiate()
		var npc_resource = NPCResource.new()
		npc_resource.texture = load(sprites_path + json_as_dict[i])
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
		var tile = tile_map.get_cell_tile_data(0, posible_position)
		if tile == null:
			recalculate = false
		
	return final_position
	
func game_over():
	var game_over_screen := GAME_OVER_MENU.instantiate()
	add_child.call_deferred(game_over_screen)

func _process(delta):
	visible_timer.text = get_time()
	
func get_time():
	var time_left = game_timer.time_left
	var minutes = floor(time_left/60)
	var seconds = int(time_left) % 60
	return "%02d:%02d" % [minutes, seconds]

func _on_cat_got_person_in_love():
	counter += 1
	cat_people_counter.text = str(counter)
	if counter == npc_to_add:
		game_over()

func _on_game_timer_timeout():
	get_tree().reload_current_scene()
