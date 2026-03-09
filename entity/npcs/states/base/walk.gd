extends NPCState

@export var walk_speed:float = 45.0
@export var turn_on_walls:bool = true

func physics(delta:float) -> void:
	if character.is_on_floor():
		character.velocity.x = walk_speed*character.direction
		character.default_sprite_handling()
	
	character.standard_physics(delta)
	
	if turn_on_walls && character.is_on_wall():
		character.direction = -character.direction
	

# animations
func process(_delta:float) -> void:
	character.default_sprite_handling()
	if character.is_on_floor():
		character.animator.play("walk")
	else:
		character.animator.play("fall")
