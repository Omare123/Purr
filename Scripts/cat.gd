class_name Cat extends CharacterBody2D
@export var UNTOUCHABLE_TIME: float = 1
@export var animation_tree: AnimationTree
@export var purr_range: Area2D
@export var sprite: Sprite2D
@onready var timer = $Timer
@onready var body = $CollisionShape2D
@onready var free = $SFX/Free
@onready var f_button = $"F Button"
signal got_person_in_love
const SPEED = 200.0

#Input actions
const LEFT = "left"
const RIGHT = "right"
const UP = "up"
const DOWN = "down"
const FREE = "free"
const PURR = "purr"


const FREE_TOTAL_COUNTS = 5
var free_actual_count = 0

enum {
	IDLE,
	WALK,
	LOVE,
	PET,
}

var state
var input_direction = Vector2.ZERO
var loved_a_person = false
var untouchable = false

func _ready():
	input_direction = Vector2(0, 1)
	update_blend_directions()
	
func _physics_process(delta):
	input_direction = Input.get_vector(LEFT, RIGHT, UP, DOWN)
	if state == PET:
		if Input.is_action_just_pressed(FREE):
			count_free()
	
	if input_direction == Vector2.ZERO and state != LOVE and state != PET:
		state = IDLE
	elif input_direction != Vector2.ZERO and state != LOVE and state != PET:
		state = WALK
	if Input.is_action_just_pressed(PURR) and state != PET:
		state = LOVE
	
	match state:
		IDLE: 
			idle_state()
		WALK:
			move_state(delta)
		LOVE:
			purr_state()
		PET:
			pet_state()
		_: 
			pass

func move_state(delta):
	if input_direction == Vector2.ZERO:
		state = IDLE
	else:
		set_animation_conditions("parameters/conditions/is_walking")
		update_blend_directions()
		
	velocity = input_direction * SPEED
	move_and_slide()

func idle_state():
	if input_direction == Vector2.ZERO:
		set_animation_conditions("parameters/conditions/idle")
	else:
		state = WALK

func purr_state():
	var got_someone = false
	set_animation_conditions("parameters/conditions/is_purring")
	for area in purr_range.get_overlapping_areas():
		body = area.get_parent()
		got_someone = true
		if body is NPC and !body.getting_in_love and !body.in_love:
			body.get_in_love()
			loved_a_person = true
			got_person_in_love.emit()
	
	if !got_someone:
		state = WALK

func pet_state():
	set_animation_conditions("parameters/conditions/pet")
	if free_actual_count == FREE_TOTAL_COUNTS:
		f_button.emitting = false
		free_actual_count = 0
		state = IDLE
		disable_body()

func getting_pet():
	state = PET
	f_button.emitting = true

func count_free():
	free_actual_count += 1
	free.play()

func disable_body(value =  false):
	if !value:
		timer.start(UNTOUCHABLE_TIME)
	untouchable = !value
	set_collision_mask_value(3, value)
	set_collision_layer_value(3, value)

func set_animation_conditions(condition):
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/is_walking"] = false
	animation_tree["parameters/conditions/is_purring"] = false
	animation_tree["parameters/conditions/pet"] = false
	animation_tree[condition] = true

func update_blend_directions():
	animation_tree["parameters/walk/blend_position"] = input_direction

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == PURR and state != PET:
		state = IDLE
		if loved_a_person:
			disable_body()
			loved_a_person = false

func _on_timer_timeout():
	disable_body(true)
