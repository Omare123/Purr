extends Node2D
const NPC_SCENE = preload("res://Scenes/Characters/npc.tscn")
@onready var cat = $Cat
@onready var tile_map: TileMap = $TileMap
@export var npc_to_add = 10

const sprites_path = "res://Assets/Sprites/"
const NPC_NAMES = "res://Resources/npc_sprite_names.json"
const npc_max_nbr = 7


func _ready():
	
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

func get_random_position():
	var recalculate = true 
	var final_position = Vector2.ZERO
	while recalculate:
		randomize()
		var x_position = randi_range(5, 2150)
		var y_position = randi_range(1100, 5)
		final_position = Vector2(x_position, y_position)
		var posible_position = tile_map.local_to_map(final_position)
		#this gets if is a obstacle to re-roll
		var tile = tile_map.get_cell_tile_data(1, posible_position)
		if tile == null:
			recalculate = false
		
	return final_position
	
