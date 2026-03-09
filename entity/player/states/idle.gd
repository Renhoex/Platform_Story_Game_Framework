extends PlayerState

func physics(delta:float) -> void:
	player.velocity.x = 0.0
	player.standard_physics(delta)
	player.animation_affix = ""

func process(_delta:float) -> void:
	player.default_sprite_handling()
	## animations
	if player.is_on_floor():
		# don't overwrite inspect animation
		if player.animation != "inspect":
			player.animation = "idle"
	else:
		player.animation = "fall"
