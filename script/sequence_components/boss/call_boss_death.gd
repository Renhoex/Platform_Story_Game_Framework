extends SequenceNode

@export var boss:Boss

func activate() -> void:
	# activate boss
	if boss:
		boss.call_death_sequence()
