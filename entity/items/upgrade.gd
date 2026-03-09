extends InteractTrigger

# set variables for gaining items (see set_item_properties.gd)
@export var item_id:String = "HealthUpgrade"
@export var set_item: Node

enum UPGRADE_TYPE {HEALTH, ROCKET}
@export var upgrade_type:UPGRADE_TYPE = UPGRADE_TYPE.HEALTH
@export var to_add:int = 5

func _ready() -> void:
	# sync values
	set_item.is_weapon = false
	set_item.item_id = item_id
	# check if current scene is in the progress memory
	if Progress.node_memory.has(get_tree().current_scene.scene_file_path):
		if Progress.node_memory[get_tree().current_scene.scene_file_path].has(get_path()):
			queue_free()


func _on_interacted(interactor: Variant) -> void:
	# add self to progress dictionary to prevent loading in again on room refresh
	# NOTE: because this is using "get_path" if you change the scene tree for this node it 
	# could cause an already collected upgrade to despawn
	# create a key for the current scene if one does not exist yet, otherwise append it
	if !Progress.node_memory.has(get_tree().current_scene.scene_file_path):
		Progress.node_memory[get_tree().current_scene.scene_file_path] = [get_path()]
	else:
		Progress.node_memory[get_tree().current_scene.scene_file_path].append(get_path())
	# increase player max health
	match(upgrade_type):
		UPGRADE_TYPE.HEALTH:
			if interactor is Player:
				interactor.health.max_health += to_add
				interactor.health.health = interactor.health.max_health
		# add ammo to rocket
		UPGRADE_TYPE.ROCKET:
			var weapon:Weapon = GlobalWeapons.weapon_objects[GlobalWeapons.WEAPONS.ROCKET]
			weapon.max_ammo += to_add
			weapon.ammo = weapon.max_ammo
	hide()


func _on_upgrade_sequence_finished() -> void:
	# remove after sequence to avoid any issues with the timeline
	queue_free()
