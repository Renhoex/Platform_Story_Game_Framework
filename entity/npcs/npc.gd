class_name CharacterNPC extends CharacterBody2D

enum STATES {IDLE, WALK}
@export var state:STATES = STATES.IDLE:
	set(value):
		if value < 0:
			state = value
		elif value != state || state_node == null:
			%StateMachine.get_child(state).exit()
			state = value
			# we're iterating through a list of nodes, 
			# if we're higher then the amount of nodes in a sate (someone deleted them) just return a null state instead
			if state >= %StateMachine.get_child_count():
				state_node = null
			else:
				state_node = %StateMachine.get_child(state)
				%StateMachine.get_child(state).enter()
var state_node:NPCState = null

@onready var has_gravity:bool = true

@export_enum("Left","Right") var direction:int = 0:
	get():
		# use get function to return -1 instead of 0
		if direction <= 0:
			return -1
		return direction

@export var sprite_group: CanvasGroup
@export var animator: AnimationPlayer
var locked:bool = false


func _ready() -> void:
	#initialize state
	state = state


func _process(delta: float) -> void:
	if state_node && !locked:
		state_node.process(delta)

func _physics_process(delta: float) -> void:
	if state_node && !locked:
		state_node.physics(delta)

func default_sprite_handling() -> void:
	sprite_group.scale.x = direction

func standard_physics(delta: float) -> void:
	if has_gravity:
		velocity += get_gravity()*delta
	move_and_slide()
	
