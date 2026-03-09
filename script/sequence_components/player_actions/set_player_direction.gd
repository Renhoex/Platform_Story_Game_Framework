extends SequenceNode

@export var player:Player
@export_enum("Left","Right") var direction:int = 0:
	get():
		# use get function to return -1 instead of 0
		if direction <= 0:
			return -1
		return direction

func activate() -> void:
	if player:
		player.direction = direction
