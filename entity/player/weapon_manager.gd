extends Node

@onready var player:Player = get_parent()
@export var projectile_list:Array[Projectile] = []
var weapon:Projectile
@export var weapon_index:GlobalWeapons.WEAPONS = GlobalWeapons.WEAPONS.NORMAL

var projectile_table:Array[Projectile] = []

func _ready() -> void:
	for i in projectile_list:
		i.show()
		i.get_parent().remove_child(i)

func _physics_process(_delta: float) -> void:
	# cycle through
	for i:Projectile in projectile_table:
		if !is_instance_valid(i):
			projectile_table.erase(i)

func fire_pressed():
	match(weapon_index):
		GlobalWeapons.WEAPONS.NORMAL, GlobalWeapons.WEAPONS.WAVE:
			weapon = projectile_list[weapon_index]
			if weapon.projectile_limit <= projectile_table.size() && weapon.projectile_limit != 0:
				return
			if %Particle.sprite_frames.has_animation(weapon.particle_animation):
				%Particle.play(weapon.particle_animation)
			
			var proj = weapon.duplicate()
			
			var rotated_fire:float = 0.0
			if player.input_manager.y_input < 0.0 || (player.input_manager.y_input > 0.0 && !player.is_on_floor()):
				rotated_fire += deg_to_rad(90.0)*player.input_manager.y_input
			
			proj.velocity = Vector2(320.0*player.direction,0.0)
			
			match(weapon_index):
				GlobalWeapons.WEAPONS.NORMAL:
					player.weapon_sounds.stream = preload("res://audio/weapons/Fire.wav")
			
			player.weapon_sounds.play()
			proj.global_position = player.fire_point.global_position
			proj.rotation = rotated_fire
			proj.scale.x = player.direction
			proj.velocity = proj.velocity.rotated(rotated_fire*player.direction)
			proj.weapon_manager = self
			projectile_table.append(proj)
			player.add_sibling(proj)
			normal_fire_animation()
			weapon_index = GlobalWeapons.WEAPONS.NORMAL

func normal_fire_animation() -> void:
	player.fire_time = 8.0/60.0
	
	if player.animation == "fire":
		player.animator.stop()
		player.animator.play("fire")
	elif player.animation == "climb_fire":
		player.animator.stop()
		player.animator.play("climb_fire")
