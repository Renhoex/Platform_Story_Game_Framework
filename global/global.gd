extends Node

var sequence_call:String = ""
var current_timeline:TimeLineHandler
const SAVE_SELECT = preload("uid://clvcypad2appk")


func convert_dialogic_string(call_string) -> Variant:
	var dialogic_var = Dialogic.VAR
	var split_vars:PackedStringArray = call_string.split(".")
	while split_vars.size() > 0:
		if dialogic_var.has(split_vars[0]):
			dialogic_var = dialogic_var.get(split_vars[0])
			split_vars.remove_at(0)
		else:
			print("Can't find dialogic variable")
			return null
	return dialogic_var

# sets variables up for an items setting (mostly so dialogic can reference data)
func set_current_item(item_id:String = "", is_weapon:bool = false) -> void:
	Dialogic.VAR.ITEMS.is_weapon = is_weapon
	if is_weapon && Weapon.weapon_keys.has(item_id):
		Dialogic.VAR.ITEMS.item_name = Weapon.weapon_keys[item_id].label
		Dialogic.VAR.ITEMS.collected = Weapon.weapon_keys[item_id].collected
	elif !is_weapon && Item.item_keys.has(item_id):
		Dialogic.VAR.ITEMS.item_name = Item.item_keys[item_id].label
		Dialogic.VAR.ITEMS.collected = Item.item_keys[item_id].collected
	Dialogic.VAR.ITEMS.item_id = item_id

func refill_players_hp() -> void:
	for i in get_tree().get_nodes_in_group("player"):
		if i is Player:
			# refill player HP
			i.health.health = i.health.max_health

func call_save_menu(is_load:bool = false, can_cancel:bool = true) -> void:
	var save = SAVE_SELECT.instantiate()
	save.loading = is_load
	save.can_cancel = can_cancel
	add_sibling(save)

func reset_game() -> void:
	Progress.reset() # this runs in the title screen but this should be handy if someone wants to change the reset room and remove the reset function
	GlobalHud.player_hud.hide()
	
	get_tree().change_scene_to_file("res://scenes/Title.tscn")
