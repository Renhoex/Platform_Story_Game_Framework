extends PlayerState

const STEP_TIME:float = 0.1
var step_time:float = 0.0

func enter() -> void:
	player.animation = "inspect"
	player.input_manager.shoot_pressed.connect(player.jump_action)
	player.input_manager.shoot_pressed.connect(exit_action)
	player.input_manager.left_pressed.connect(exit_action)
	player.input_manager.right_pressed.connect(exit_action)
	player.input_manager.up_pressed.connect(exit_action)
	# check if there's any overlapping inspecting points
	if %InteractBox.has_overlapping_areas():
		var get_overlap_area:Area2D = %InteractBox.get_overlapping_areas()[0]
		if get_overlap_area is InteractTrigger:
			if !get_overlap_area.activate_on_touch:
				player.interact_trigger(get_overlap_area)
				
			
	else:
		%Inspect.restart()
		%Inspect.emitting = true

func exit() -> void:
	player.input_manager.shoot_pressed.disconnect(player.jump_action)
	player.input_manager.shoot_pressed.disconnect(exit_action)
	player.input_manager.left_pressed.disconnect(exit_action)
	player.input_manager.right_pressed.disconnect(exit_action)
	player.input_manager.up_pressed.disconnect(exit_action)

func physics(delta:float) -> void:
	player.standard_physics(delta)
	player.velocity.x = move_toward(player.velocity.x,0.0,delta * player.MOMENTUM)
	if !player.is_on_floor():
		exit_action()


func exit_action() -> void:
	player.state = player.STATES.NORMAL
