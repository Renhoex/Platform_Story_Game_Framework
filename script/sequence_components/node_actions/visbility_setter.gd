extends SequenceNode

enum VISIBILITY {HIDE, SHOW, TOGGLE}
@export var set_visibility:VISIBILITY = VISIBILITY.HIDE
@export var set_node:Node2D

# toggle the visibility
func activate() -> void:
	if set_node:
		if set_visibility == VISIBILITY.TOGGLE:
			set_node.visible = !set_node.visible
		else:
			set_node.visible = set_visibility
