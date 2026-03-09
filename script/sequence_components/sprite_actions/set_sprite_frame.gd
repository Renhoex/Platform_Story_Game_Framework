extends SequenceNode

@export var sprite:Sprite2D
@export var set_frame:int = 0

func activate() -> void:
	if sprite:
		sprite.frame = set_frame
