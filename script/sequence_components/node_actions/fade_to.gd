extends SequenceNode

@export var color_fade:Color = Color.BLACK
@export var fade_time:float = 1.0

# fade the overlay
func activate() -> void:
	GlobalOverlay.fade(color_fade,fade_time)
