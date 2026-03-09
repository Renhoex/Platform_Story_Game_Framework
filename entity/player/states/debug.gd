extends PlayerState

func physics(delta:float) -> void:
	player.translate(Vector2(player.input_manager.x_input,player.input_manager.y_input) * delta * 320.0)
