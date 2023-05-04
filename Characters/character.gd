extends CharacterBody2D

enum STATE { IDLE, WALK }

@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0, 1)
@export var is_npc : bool = true
@export var idle_time : float = 5
@export var walk_time : float = 2

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var sprite = $Sprite2D
@onready var timer = $Timer

var move_direction : Vector2 = Vector2.ZERO
var current_state : STATE = STATE.IDLE

func _ready():
	update_animation_parameters(starting_direction)
	pick_new_state()
	
func _physics_process(_delta):
	
	if ! is_npc:
		# Get input direction
		move_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	# Update velocity
	velocity = move_direction * move_speed
	set_animation()
	update_animation_parameters(move_direction)
	
	# Move and Slide function uses velocity of character body to move character on map
	move_and_slide()

func select_new_direction():
	move_direction = Vector2(
				randi_range(-1,1),
				randi_range(-1,1)
			)
	if move_direction.x < 0:
		sprite.flip_h = true
	elif move_direction.x > 0:
		sprite.flip_h = false
			
func update_animation_parameters(move_input : Vector2):
	# Don't change animation parameters if there is no move input
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		
# Choose state based on what is happening with the player (are we moving or idle)
func pick_new_state():
	if is_npc:
		if current_state == STATE.IDLE:
			current_state = STATE.WALK
			select_new_direction()
			timer.start(walk_time)
		elif current_state == STATE.WALK:
			current_state = STATE.IDLE
			move_direction = Vector2.ZERO
			timer.start(idle_time)
			
func set_animation():
		if(velocity != Vector2.ZERO):
			state_machine.travel("Walk")
		else:
			state_machine.travel("Idle")


func _on_timer_timeout():
	pick_new_state()
