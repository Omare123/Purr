extends CharacterBody2D
class_name NPC
@export var npc_resource: NPCResource
@export var player: CharacterBody2D
@export var animation_tree: AnimationTree
@onready var sprite_2d = $Sprite2D
@onready var bubble_dog = $BubbleDog
@onready var hearts = $Hearts

enum {
	IDLE,
	WALK,
	LOVE,
	CHASE,
	PET
}

const SPEED = 100.0
var direction = Vector2.ZERO
var getting_in_love = false
var in_love = false
var state = IDLE
func _ready():
	sprite_2d.texture = npc_resource.texture

func _physics_process(delta):
	match state:
		IDLE: 
			idle_state()
		WALK:
			move_state(delta)
		LOVE:
			love_state()
		CHASE:
			chasing_state()
		PET:
			pet_state()
		_: 
			pass

func idle_state():
	if getting_in_love:
		return
	
	if direction != Vector2.ZERO:
		state = WALK
	else:
		set_animation_conditions("parameters/conditions/idle")
	
func move_state(delta):
	if getting_in_love:
		return
	direction = position.direction_to(player.position).normalized()
	velocity = direction * SPEED
	if direction == Vector2.ZERO:
		state = IDLE
	else:
		velocity = direction * SPEED
		update_blend_directions()
		set_animation_conditions("parameters/conditions/is_walking")
	move_and_slide()

func chasing_state():
	if getting_in_love:
		return
	direction = position.direction_to(player.position).normalized()
	velocity = direction * SPEED
	update_blend_directions()
	set_animation_conditions("parameters/conditions/is_chasing")
	move_and_slide()
	
func love_state():
	getting_in_love = true
	set_animation_conditions("parameters/conditions/in_love")

func pet_state():
	set_animation_conditions("parameters/conditions/pet")
	if player.state != 3:
		state = CHASE
		hearts.emitting = false

func set_animation_conditions(condition):
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/in_love"] = false
	animation_tree["parameters/conditions/is_walking"] = false
	animation_tree["parameters/conditions/is_chasing"] = false
	animation_tree["parameters/conditions/pet"] = false
	animation_tree[condition] = true

func update_blend_directions():
	animation_tree["parameters/walk/blend_position"] = direction.x
	animation_tree["parameters/chase/blend_position"] = direction.x

func get_in_love():
	state = LOVE

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "in_love":
		getting_in_love = false
		in_love = true
		bubble_dog.emitting = false
		state = CHASE

func _on_petting_range_body_entered(body):
	if body is Cat and state == CHASE:
		body.getting_pet()
		state = PET
