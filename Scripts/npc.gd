extends CharacterBody2D
class_name NPC
@export var limit_up_left = Vector2(5,5)
@export var limit_down_right = Vector2(1690,1125)
@export var tile_map: TileMap
@export var npc_resource: NPCResource
@export var player: CharacterBody2D
@export var animation_tree: AnimationTree
@onready var sprite_2d = $Sprite2D
@onready var bubble_dog = $BubbleDog
@onready var hearts = $Hearts
@onready var target_position = global_position
@export var navigation_agent: NavigationAgent2D
@export var navigation_timer: Timer

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
var last_checked_position = Vector2.ZERO

func _ready():
	sprite_2d.texture = npc_resource.texture
	navigation_timer.wait_time = randf_range(3, 8)

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
	navigation_agent.path_max_distance
	velocity = direction * SPEED
	if navigation_agent.is_navigation_finished():
		state = IDLE
	else:
		update_blend_directions()
		set_animation_conditions("parameters/conditions/is_walking")
		move_and_slide()

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
		
func game_over_celebrate():
	set_animation_conditions("parameters/conditions/pet")
	navigation_timer.stop()
	
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
	navigation_timer.stop()
	navigation_timer.wait_time = 0.1
	navigation_timer.start()

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

func update_target_position():
	if state == IDLE:
		state = WALK
		target_position = get_random_position()

func _on_stuck_timer_timeout():
	if position.distance_to(last_checked_position) < 0.5 and state == WALK:
		state = IDLE
		update_target_position()
	last_checked_position = position
