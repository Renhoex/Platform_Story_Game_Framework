extends NPCState

@export var stop_when_activated:bool = true

func enter() -> void:
	character.animator.play("idle")
	if stop_when_activated:
		character.velocity.x = 0.0
	
func physics(delta:float) -> void:
	character.standard_physics(delta)

func process(_delta:float) -> void:
	character.default_sprite_handling()
