extends Enemy

var ticker:float = 0.0
const GENERIC_PROJECTILE = preload("uid://baygwyeswonkg")

func _physics_process(delta: float) -> void:
	$Sprite.scale.x = abs($Sprite.scale.x)*float(direction)
	if $PlayerCheck.has_overlapping_bodies():
		$Sprite/Sprite.frame = 0
		$HitboxComponent.hit_action = HitboxComponent.HIT_ACTIONS.DAMAGE
		ticker += delta
		# fire
		if ticker >= 1.0:
			ticker = 0.0
			var proj = GENERIC_PROJECTILE.instantiate()
			add_sibling(proj)
			proj.global_position = global_position+Vector2(float(direction)*16.0,0.0)
			proj.velocity = Vector2(float(direction)*60.0,0.0)
		# look at player
		get_player()
		if player:
			if player.global_position.x < global_position.x:
				direction = -1
			else:
				direction = 1
	else:
		$Sprite/Sprite.frame = 1
		$HitboxComponent.hit_action = HitboxComponent.HIT_ACTIONS.DEFLECT
		ticker = 0.0
