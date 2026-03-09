extends PlayerState



func enter() -> void:
	player.input_manager.jump_pressed.connect(player.jump_action)
	player.input_manager.down_pressed.connect(inspect)
	

func exit() -> void:
	if player.input_manager.jump_pressed.has_connections():
		player.input_manager.jump_pressed.disconnect(player.jump_action)
		player.input_manager.down_pressed.disconnect(inspect)

func physics(delta:float) -> void:
	var move_speed:float = player.WALK
	# face direction of input
	if player.input_manager.x_input:
		player.direction = sign(player.input_manager.x_input)
	
	if player.is_on_floor() || player.input_manager.x_input != 0.0:
		player.velocity.x = move_toward(player.velocity.x,player.input_manager.x_input*move_speed,delta * player.MOMENTUM)
	player.standard_physics(delta)
	if player.input_manager.y_input < 0.0:
		player.animation_affix = "_up"
	elif player.input_manager.y_input > 0.0:
		player.animation_affix = "_down"
	else:
		player.animation_affix = ""


func process(_delta:float) -> void:
	player.default_sprite_handling()
	## animations
	if player.is_on_floor():
		if player.velocity.x == 0.0:
			player.animation = "idle"
		else:
			player.animation = "walk"
	
	elif player.velocity.y < 0:
		player.animation = "jump"
	else:
		player.animation = "fall"

func inspect() -> void:
	if player.is_on_floor():
		player.state = player.STATES.INSPECT
