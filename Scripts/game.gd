extends Node2D
const NPC_SCENE = preload("res://Scenes/Characters/npc.tscn")
@onready var cat = $Cat
const sprites_path = "res://Assets/Sprites/"
const NPC_NAMES = "res://Resources/npc_sprite_names.json"
const npc_max_nbr = 7
const npc_to_add = 10

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
		print(sprites_path + json_as_dict[i])
		img.load(sprites_path + json_as_dict[i])
		npc_resource.texture = tex.create_from_image(img)
		npc.npc_resource = npc_resource
		npc.player = cat
		npc.position = Vector2(i, 0)
		add_child(npc)
