extends CharacterBody2D
class_name NPC
@export var npc_resource: NPCResource
@export var player: CharacterBody2D
@export var animation_tree: AnimationTree
@onready var sprite_2d = $Sprite2D
@onready var bubble_dog = $BubbleDog
@onready var hearts = $Hearts
@onready var start_position = global_position
@onready var target_position = global_position
@export var wander_range = 32
@export var navigation_agent: NavigationAgent2D
@export var navigation_timer: Timer
@onready var wander_timer = $WanderTimer

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

	set_animation_conditions("parameters/conditions/idle")
	
func move_state(delta):
	if getting_in_love:
		return
	direction = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = direction * SPEED
	if direction.length() < 1:
		state = IDLE
	else:
		update_blend_directions()
		set_animation_conditions("parameters/conditions/is_walking")
		move_and_collide(direction)

func chasing_state():
	if getting_in_love:
		return
	direction = to_local(navigation_agent.get_next_path_position()).normalized()
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
	navigation_timer.wait_time = 0.1

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "in_love":
		getting_in_love = false
		in_love = true
		bubble_dog.emitting = false
		state = CHASE

func _on_petting_range_area_entered(area):
	var area_body = area.get_parent() 
	if area_body is Cat and state == CHASE and !area_body.untouchable:
		area_body.getting_pet()
		state = PET
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_navigation_timer_timeout():
	if state == CHASE:
		navigation_agent.target_position = player.global_position
	else:
		update_target_position()
		navigation_agent.target_position = target_position

func update_target_position():
	var target_vector = Vector2(randf_range(-wander_range, wander_range), randf_range(-wander_range, wander_range))
	if state == IDLE:
		state = WALK
		target_position = start_position + target_vector

func _on_wander_timer_timeout():
	pass
