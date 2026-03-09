extends Node

signal weapon_changed

var weapon:Weapon
var weapon_objects:Array[Weapon] = []
@onready var weapon_node_container: Node = $Weapons
@onready var projectiles: Node = $Projectiles


# while not necessary 
enum WEAPONS {NONE = -1, NORMAL, MACHINE, WAVE, ROCKET}
var weapon_index:WEAPONS = WEAPONS.NONE:
	set(value):
		# check if weapon index is in range
		if value == WEAPONS.NONE:
			weapon_index = value
			weapon = null
			weapon_changed.emit()
		elif value < weapon_objects.size():
			if weapon_objects[value].collected:
				weapon_index = value
				weapon = weapon_objects[value]
				weapon_changed.emit()

func _ready() -> void:
	# add weapon objects to list
	for i in weapon_node_container.get_children():
		if i is Weapon:
			weapon_objects.append(i)
			# remove projectile from scene tree if there's a pointer
			if i.projectile:
				# make sure the node's inside the tree (two weapons might use the same projectile)
				if i.projectile.is_inside_tree():
					i.projectile.get_parent().remove_child(i.projectile)
	
	
	# clear our stray projectiles
	for i in projectiles.get_children():
		i.queue_free()

func quick_switch(direction:int = 1) -> void:
	var loop_break_counter:int = 0
	var get_wep_index:int = weapon_index
	while !weapon_objects[wrapi(get_wep_index,0,weapon_objects.size())].collected &&\
	loop_break_counter < weapon_objects.size() || loop_break_counter == 0:
		loop_break_counter += 1
		get_wep_index = wrapi(get_wep_index+direction,0,weapon_objects.size())
	
	weapon_index = get_wep_index as WEAPONS

func unlock_weapon(weapon_id:String = ""):
	if weapon_node_container.has_node(weapon_id):
		var get_weapon:Weapon = weapon_node_container.get_node(weapon_id)
		get_weapon.collected = true
		weapon_index = get_weapon.get_index() as WEAPONS
		if Dialogic.VAR.ITEMS.item_id == weapon_id:
			Dialogic.VAR.ITEMS.collected = true

func refill_all_ammo():
	for i:Weapon in weapon_objects:
		i.ammo = i.max_ammo
