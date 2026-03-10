extends Node

# node memory is supposed to contain a list of data for the currently to look up from the currently scene file path
# for an example see health_upgrade.gd
var node_memory:Dictionary[String,PackedStringArray]
var play_time:float = 0.0


const SAVE_FILE_COUNT:int = 8
var save_file_id:int = 0

func reset() -> void:
	node_memory.clear()
	# reset dialogic
	Dialogic.clear()
	play_time = 0.0
	# reset items and weapons
	for i:String in Weapon.weapon_keys.keys():
		Weapon.weapon_keys[i].reset_to_default()
	for i:String in Item.item_keys.keys():
		Item.item_keys[i].reset_to_default()
	GlobalWeapons.weapon_index = GlobalWeapons.WEAPONS.NONE
	Player.max_health = 0 # set player max health to 0 so that it can be reset
	Global.sequence_call = ""
	

func _process(delta: float) -> void:
	play_time += delta

func save_data() -> void:
	var data_dic:Dictionary
	data_dic["date_time"] = Time.get_datetime_dict_from_system()
	data_dic["play_time"] = play_time
	data_dic["current_scene"] = get_tree().current_scene.scene_file_path
	data_dic["room_name"] = get_tree().current_scene.name.capitalize()
	data_dic["node_memory"] = node_memory
	# save dialogic data
	data_dic["dialogic_data"] = Dialogic.get_full_state()
	# add player
	var player:Player = get_tree().get_first_node_in_group("player")
	if player:
		data_dic["player_position"] = player.global_position
		data_dic["player_direction"] = player.direction
		data_dic["player_max_health"] = player.health.max_health
		data_dic["player_health"] = player.health.health
	# weapons
	data_dic["current_weapon"] = GlobalWeapons.weapon_index
	# record data on weapons, you might want to update this to record information in relation to weapons
	for i:Weapon in GlobalWeapons.weapon_objects:
		var weapon_data:Dictionary
		weapon_data["collected"] = i.collected
		weapon_data["max_ammo"] = i.max_ammo
		weapon_data["ammo"] = i.ammo
		# add weapon using the node name
		data_dic["weapon_"+str(i.name)] = weapon_data
	
	# record item data
	for i:Item in GlobalItems.get_children():
		var item_data:Dictionary
		item_data["collected"] = i.collected
		# add item using the node name
		data_dic["item_"+str(i.name)] = item_data
	
	# save data to file
	var file = FileAccess.open("user://save"+str(save_file_id)+".save", FileAccess.WRITE)
	file.store_var(data_dic)


func load_game() -> bool:
	# reset settings before loading
	reset()
	var file_path:String = "user://save"+str(save_file_id)+".save"
	if !FileAccess.file_exists(file_path): return false
	var file_open = FileAccess.open(file_path, FileAccess.READ)
	var data_read:Dictionary = file_open.get_var()
	
	# load data
	play_time = load_dictionary_data(data_read,"play_time",0.0)
	node_memory = load_dictionary_data(data_read,"node_memory",node_memory)
	
	# set static player variables
	Player.direction = load_dictionary_data(data_read,"player_direction",Player.direction)
	Player.spawn_point = load_dictionary_data(data_read,"player_position",Player.spawn_point)
	Player.go_to_spawn = true
	
	Dialogic.load_full_state(load_dictionary_data(data_read,"dialogic_data",Dialogic.get_full_state()))
	
	# read weapon data
	for i:Weapon in GlobalWeapons.weapon_objects:
		if data_read.has("weapon_"+str(i.name)):
			# get the weapon data
			var weapon_data:Dictionary = data_read["weapon_"+str(i.name)]
			i.collected = load_dictionary_data(weapon_data,"collected",i.collected)
			i.max_ammo = load_dictionary_data(weapon_data,"max_ammo",i.max_ammo)
			i.ammo = load_dictionary_data(weapon_data,"ammo",i.ammo)
	
	GlobalWeapons.weapon_index = load_dictionary_data(data_read,"current_weapon",GlobalWeapons.weapon_index)
	# read item data
	for i:Item in GlobalItems.get_children():
		if data_read.has("item_"+str(i.name)):
			# get the weapon data
			var item_data:Dictionary = data_read["item_"+str(i.name)]
			i.collected = load_dictionary_data(item_data,"collected",i.collected)
	
	# load into the stage
	get_tree().change_scene_to_file(load_dictionary_data(data_read,"current_scene",get_tree().current_scene.scene_file_path))
	# load the player health values after loading a new scene, if max health isn't 0 when the player's removed
	# the player max health value is overrided
	# these load in before _ready()
	Player.max_health = load_dictionary_data(data_read,"player_max_health",Player.max_health)
	Player.current_health = load_dictionary_data(data_read,"player_health",Player.current_health)
	return true

func load_dictionary_data(get_dictionary:Dictionary, key:String = "", default:Variant = null) -> Variant:
	if get_dictionary.has(key):
		return get_dictionary[key]
	return default

func has_saves() -> bool:
	# loop through the save file count and see if a save file exists
	for i in SAVE_FILE_COUNT:
		if FileAccess.file_exists("user://save"+str(i)+".save"):
			return true
	return false
