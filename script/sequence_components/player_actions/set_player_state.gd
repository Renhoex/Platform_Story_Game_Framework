extends SequenceNode

@export var player:Player
@export var state:Player.STATES

func activate() -> void:
	if player:
		player.state = state
