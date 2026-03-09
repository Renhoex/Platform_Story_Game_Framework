extends Enemy

@onready var y_start:float = global_position.y

func _ready() -> void:
	super()
	velocity.y = 60.0

func _physics_process(delta: float) -> void:
	$Sprite.scale.x = abs($Sprite.scale.x)*float(direction)
	if global_position.y < y_start:
		velocity.y += 120.0*delta
	else:
		velocity.y -= 120.0*delta
	move_and_slide()
	# look at player
	get_player()
	if player:
		if player.global_position.x < global_position.x:
			direction = -1
		else:
			direction = 1
