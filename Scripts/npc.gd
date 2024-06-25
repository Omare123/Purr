extends CharacterBody2D
class_name NPC
@export var npc_resource: NPCResource
@onready var sprite_2d = $Sprite2D
@onready var animation_tree = $AnimationTree

const SPEED = 300.0
var direction = Vector2.ZERO
var getting_in_love = false
var in_love = false

func _ready():
	sprite_2d.texture = npc_resource.texture

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if(direction == Vector2.ZERO) and !getting_in_love:
		set_animation_conditions("parameters/conditions/idle")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func set_animation_conditions(condition):
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/in_love"] = false
	animation_tree["parameters/conditions/is_walking"] = false
	animation_tree[condition] = true
	
func get_in_love():
	getting_in_love = true
	set_animation_conditions("parameters/conditions/in_love")


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "in_love":
		getting_in_love = false
		in_love = true
