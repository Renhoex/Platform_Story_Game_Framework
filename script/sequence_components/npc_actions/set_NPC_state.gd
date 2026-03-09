extends SequenceNode

@export var character:CharacterNPC
@export var state:CharacterNPC.STATES

func activate() -> void:
	if character:
		character.state = state
