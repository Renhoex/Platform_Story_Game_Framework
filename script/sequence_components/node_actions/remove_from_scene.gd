extends SequenceNode

@export var remove_at_start:bool = true
@export var add_on_call:bool = true
@export var set_node:Node2D
var get_node_parent:Node

func _ready() -> void:
	if set_node:
		get_node_parent = set_node.get_parent()
	# allow for frame so that other nodes can get the pointer
	await get_tree().physics_frame
	if remove_at_start && set_node:
		if set_node.is_inside_tree():
			set_node.get_parent().remove_child(set_node)

# toggle the visibility
func activate() -> void:
	if set_node:
		# if add on call then add the node to the scene (if it's not currently in scene)
		if add_on_call:
			if !set_node.is_inside_tree(): # check if not in scene
				get_node_parent.add_child(set_node)
		# if add on activate is false, then remove the node
		elif set_node.is_inside_tree(): # check if in scene
			set_node.get_parent().remove_child(set_node)
