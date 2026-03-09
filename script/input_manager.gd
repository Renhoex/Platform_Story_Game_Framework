class_name InputManager extends Node

var x_input:float = 0.0
var y_input:float = 0.0

var button_jump:bool = false
var button_shoot:bool = false
var button_action:bool = false
var button_action2:bool = false

var button_l:bool = false
var button_r:bool = false

var button_start:bool = false
var button_select:bool = false

signal jump_pressed
signal shoot_pressed
signal action_pressed
signal action2_pressed
signal l_pressed
signal r_pressed
signal start_pressed
signal select_pressed
signal up_pressed
signal down_pressed
signal left_pressed
signal right_pressed

signal jump_released
signal shoot_released
signal action_released
signal action2_released
signal start_released
signal select_released
signal up_released
signal down_released
signal left_released
signal right_released
signal l_released
signal r_released

var input_lookup:Array[PackedStringArray] = [["gm_jump","jump_pressed","jump_released"],
["gm_shoot","shoot_pressed","shoot_released"],
["gm_action","action_pressed","action_released"],
["gm_action2","action2_pressed","action2_released"],

["gm_shoulder_l","l_pressed","l_released"],
["gm_shoulder_r","r_pressed","r_released"],

["gm_start",		"start_pressed",		"start_released"],
["gm_select",	"select_pressed",	"select_released"],

["gm_up",	"up_pressed",	"up_released"],
["gm_down",	"down_pressed",	"down_released"],
["gm_left",	"left_pressed",	"left_released"],
["gm_right",	"right_pressed",	"right_released"],
]

var locked = false

func _process(_delta: float) -> void:
	if locked:
		reset_input()
		return
	update_input()

func reset_input(_including_fire = false) -> void:
	x_input = 0.0
	y_input = 0.0

	button_jump = false
	button_shoot = false
	button_action = false
	button_action2 = false

	button_l = false
	button_r = false

	button_start = false
	button_select = false

func update_input() -> void:
	x_input = Input.get_axis("gm_left","gm_right")
	y_input = Input.get_axis("gm_up","gm_down")
	
	button_jump = Input.is_action_pressed("gm_jump")
	button_shoot = Input.is_action_pressed("gm_shoot")
	button_action = Input.is_action_pressed("gm_action")
	button_action2 = Input.is_action_pressed("gm_action2")
	
	button_l = Input.is_action_pressed("gm_shoulder_l")
	button_r = Input.is_action_pressed("gm_shoulder_r")
	
	button_start = Input.is_action_pressed("gm_start")
	button_select = Input.is_action_pressed("gm_select")


func _input(event: InputEvent) -> void:
	if locked: return
	for i in input_lookup:
		if event.is_action_pressed(i[0]):
			update_input()
			emit_signal(i[1])
			return
		elif event.is_action_released(i[0]):
			update_input()
			emit_signal(i[2])
			return

# this is basically to get rid of the warning, you can use it for fun if you want
func emit_all() -> void:
	jump_pressed.emit()
	shoot_pressed.emit()
	action_pressed.emit()
	action2_pressed.emit()
	l_pressed.emit()
	r_pressed.emit()
	start_pressed.emit()
	select_pressed.emit()
	up_pressed.emit()
	down_pressed.emit()
	left_pressed.emit()
	right_pressed.emit()
	jump_released.emit()
	shoot_released.emit()
	action_released.emit()
	action2_released.emit()
	start_released.emit()
	select_released.emit()
	up_released.emit()
	down_released.emit()
	left_released.emit()
	right_released.emit()
	l_released.emit()
	r_released.emit()
