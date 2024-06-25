class_name Cat extends CharacterBody2D

@export var animation_tree: AnimationTree
@export var body_area: Area2D
@export var sprite: Sprite2D

const SPEED = 200.0

#Input actions
const LEFT = "left"
const RIGHT = "right"
const UP = "up"
const DOWN = "down"

const INVENCIBILITY_TIME = 1

enum {
	IDLE,
	WALK,
	PURR,
}

var state
var input_direction = Vector2.ZERO

func _ready():
	input_direction = Vector2(0, 1)
	update_blend_directions()
	
func _physics_process(delta):
	input_direction = Input.get_vector(LEFT, RIGHT, UP, DOWN)
	if input_direction == Vector2.ZERO:
		state = IDLE
	elif input_direction != Vector2.ZERO and state != PURR:
		state = WALK
		
	if Input.is_action_just_pressed("purr"):
		state = PURR
	match state:
		IDLE: 
			pass
		WALK:
			move_state(delta)
		PURR:
			purr_state()
		_: 
			pass

func move_state(delta):
	if input_direction == Vector2.ZERO:
		set_animation_conditions("parameters/conditions/idle")
	else:
		set_animation_conditions("parameters/conditions/is_walking")
		update_blend_directions()
		
	velocity = input_direction * SPEED
	move_and_slide()
	
func set_animation_conditions(condition):
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/is_walking"] = false
	animation_tree["parameters/conditions/is_purring"] = false
	animation_tree[condition] = true

func update_blend_directions():
	#animation_tree["parameters/idle/blend_position"] = input_direction
	animation_tree["parameters/walk/blend_position"] = input_direction

func purr_state():
	set_animation_conditions("parameters/conditions/is_purring")
	for bodie in body_area.get_overlapping_bodies():
		if bodie is NPC and !bodie.getting_in_love and !bodie.in_love:
			bodie.get_in_love()

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == 'purr':
		state = WALK
