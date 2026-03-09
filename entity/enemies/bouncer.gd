extends Enemy

@onready var sub_sprite: Sprite2D = $Sprite/Sprite

func _physics_process(delta: float) -> void:
	$Sprite.scale.x = abs($Sprite.scale.x)*float(direction)
	velocity += get_gravity()*delta
	if is_on_floor():
		sub_sprite.frame = 1
		velocity.y = -120.0
	elif !move_and_collide(Vector2.DOWN*4.0,true):
		sub_sprite.frame = 0
	velocity.x = float(direction)*10.0
	if is_on_wall():
		direction = int(sign(get_wall_normal().x))
	move_and_slide()
