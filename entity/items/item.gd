extends Area2D

enum ITEM {HEALTH, ROCKET}
var item_type:ITEM = ITEM.HEALTH:
	set(value):
		item_type = value
		match(item_type):
			ITEM.HEALTH:
				sprite.play("heart")
			ITEM.ROCKET:
				sprite.play("rocket")
				# check rocket exists, if it doesn't then delte self
				if !GlobalWeapons.weapon_objects[GlobalWeapons.WEAPONS.ROCKET].collected:
					queue_free()
		

var health_refill:int = 5
var rocket_refill:int = 5

@onready var sprite: AnimatedSprite2D = $Sprite

# leave at 0 to not have a limit
@export var life_time:float = 0.0


# use this to try and figure out what type of item to choose (usually used for stuff like enemies)
func determine_item() -> void:
	var player:Player = get_tree().get_first_node_in_group("player")
	# scales on a range from 0 to 1
	var health_odds:float = remap(float(player.health.health)/float(player.health.max_health),0.0,1.0,0.35,1.0)
	# scale health odds, having it be too low can cause hearts to apear too much
	
	var rocket:Weapon = GlobalWeapons.weapon_objects[GlobalWeapons.WEAPONS.ROCKET]
	var rocket_odds:float = remap(float(rocket.ammo)/float(rocket.max_ammo),0.0,1.0,0.35,1.0)
	# run random
	if randf() >= health_odds:
		# if the random float is above the health odds, then spawn a heart
		item_type = ITEM.HEALTH
		return
	# else check for rockets
	elif randf() >= rocket_odds:
		# if the random float is above the rocket odds, then spawn a rocket
		item_type = ITEM.ROCKET
		return
	else:
		# else delete self
		queue_free()

func _physics_process(delta: float) -> void:
	if life_time > 0.0:
		life_time -= delta
		# if below two second, rapidly flash visibility
		if life_time <= 2.0:
			sprite.visible = !sprite.visible
		# delete if below zero
		if life_time <= 0.0:
			queue_free()

# collect
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		match(item_type):
			ITEM.HEALTH:
				body.health.health += health_refill
			ITEM.ROCKET:
				GlobalWeapons.weapon_objects[GlobalWeapons.WEAPONS.ROCKET].ammo += rocket_refill
				GlobalHud.update_weapon_info()
		queue_free()
