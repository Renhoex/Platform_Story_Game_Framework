extends SequenceNode

@export var player:Player
@export var lock_player:bool = false

func activate() -> void:
	if player:
		player.locked = lock_player
