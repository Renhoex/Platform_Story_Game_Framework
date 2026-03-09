extends SequenceNode

@export var teleport_to:Node2D
@export var node_to_teleport:Node2D


# teleport the node
func activate() -> void:
	if teleport_to && node_to_teleport:
		node_to_teleport.global_position = teleport_to.global_position
		# move and slide if the node is a player to stop landing issues
		if node_to_teleport is Player:
			node_to_teleport.move_and_slide()
