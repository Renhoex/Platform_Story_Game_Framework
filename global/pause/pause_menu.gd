extends CanvasLayer

var selected_node:Control = null:
	set(value):
		selected_node = value
		# default decription box to a blank
		description_box.text = ""
		# if item list update description box
		if selected_node != null:
			if selected_node.get_parent() == %ItemList:
				description_box.text = GlobalItems.get_child(selected_node.get_index()).label

const MENU_WEAPON = preload("uid://cfqgyldu0hsc7")
const MENU_ITEM = preload("uid://ba5nes6l5g4sg")

@onready var description_box: RichTextLabel = $InfoBox/RichTextLabel

func _ready() -> void:
	hide()
	update_items()
	Dialogic.timeline_started.connect(lock_input_manager.bind(true))
	Dialogic.timeline_ended.connect(lock_input_manager.bind(false))



func _process(_delta: float) -> void:
	if !visible || selected_node == null: return
	# scroll offset for weapons if the total overalaps the edge
	var scroll_to_x:float = (-max(0.0,GlobalWeapons.weapon_index-4) * 40.0 )
	# overwrite the scroll if the selected node is one of the weapons
	if selected_node.get_parent() == %WeaponList:
		scroll_to_x = min(0.0,-selected_node.position.x+($Weapons.size.x/2.5))
		%WeaponList.position.x = scroll_to_x+1.0
	else:
		# scroll item list
		%ItemList.position.y = min(0.0,-selected_node.position.y+48.0)
	
	
	if %WeaponList.get_child_count() > 0:
		var get_control:Control = %WeaponList.get_child(GlobalWeapons.weapon_index)
		%SelectedWeapon.global_position = get_control.global_position-Vector2(1.0,1.0)
	
	$Highlighter.global_position = selected_node.global_position-Vector2(2.0,2.0)
	$Highlighter.size = selected_node.size+Vector2(4.0,4.0)
	

func pause() -> void:
	get_tree().paused = true
	show()
	
	# update weapons
	update_weapons()
	# update items
	update_items()
	# reset selected node
	selected_node = null
	
	%Highlighter.hide() # hide the highlighter by default incase we don't find any highlightable nodes.
	
	# check if there's any weapons to highlight
	if GlobalWeapons.weapon_objects[GlobalWeapons.weapon_index].collected:
		selected_node = %WeaponList.get_child(GlobalWeapons.weapon_index)
		%SelectedWeapon.show()
		%Highlighter.show()
	# if there isn't any weapon selected select first available weapon
	if selected_node == null:
		for i in %WeaponList.get_children():
			# find the first weapon that has been collected, then break the loop
			if GlobalWeapons.weapon_objects[i.get_index()].collected:
				selected_node = i
				%Highlighter.show()
				break
	# if not, check if there's any items to highlight instead
	if selected_node == null:
		%SelectedWeapon.hide() # hide weapon highlighter if no weapons are found
		for i in %ItemList.get_children():
			# find the first item that has been collected, then break the loop
			if GlobalItems.get_child(i.get_index()).collected:
				selected_node = i
				%Highlighter.show()
				break
	
	# delay frame to prevent immediate unpause
	await get_tree().process_frame
	$InputManager.process_mode = Node.PROCESS_MODE_INHERIT

func unpause() -> void:
	get_tree().paused = false
	$InputManager.process_mode = Node.PROCESS_MODE_DISABLED
	hide()


func lock_input_manager(lock_input:bool = true) -> void:
	if !visible: return
	
	$InputManager.locked = lock_input
	# this method is hacky but dialogic only runs when the scene isn't paused,
	# as a work around we can unpause the scene but lock the current scene
	get_tree().paused = !lock_input
	if lock_input:
		get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		get_tree().current_scene.process_mode = Node.PROCESS_MODE_INHERIT

# direction, 1 is right, -1 is left, we can use this to calculate what direction the player is pressing
func select_direction(direction:int = 1) -> void:
	if selected_node == null:
		return
	# change action depending on parent node
	if selected_node.get_parent() == %WeaponList:
		# put in a variable just to make sure the while loop starts at least once
		var first_shift:bool = true
		while !selected_node.visible || first_shift:
			selected_node = %WeaponList.get_child(wrapi(selected_node.get_index()+direction,0,%WeaponList.get_child_count()))
			first_shift = false
	# check if we're on the item list, then move left and right 
	elif selected_node.get_parent() == %ItemList:
		selected_node = %ItemList.get_child(clamp(selected_node.get_index()+direction,0,%ItemList.get_child_count()-1))

# direction, 1 is down, -1 is up, we can use this to calculate what direction the player is pressing
func select_vert(direction:int = 1) -> void:
	if selected_node == null:
		return
	# change action depending on parent node
	if selected_node.get_parent() == %WeaponList:
		if direction > 0:
			# if in the weapon list, choose the first item in the item list (if item list is collectd)
			for i in %ItemList.get_children():
				# check that we don't go out of range
				if i.get_index() < GlobalItems.get_child_count():
					# grab the first collected item
					if GlobalItems.get_child(i.get_index()).collected:
						selected_node = i
						break
	# check if we're on the item list, then move by the amount of columns
	elif selected_node.get_parent() == %ItemList:
		# if pressing up and below the collumn amount
		if direction < 0 && selected_node.get_index() < %ItemList.columns:
			# if we have a weapon then select the weapon
			if GlobalWeapons.weapon:
				# make sure to select the currently equipped weapon
				selected_node = %WeaponList.get_child(GlobalWeapons.weapon_index)
				return # return to cut the rest of the script off
			# else select the first weapon that exists
			else:
				for i in %WeaponList.get_children():
					# check that we don't go out of range
					if i.get_index() < GlobalWeapons.weapon_objects.size():
						# grab the first collected weapon
						if GlobalWeapons.weapon_objects[i.get_index()].collected:
							selected_node = i
							break
					
				
		
		# check that increasing and won't go over the limit
		if (direction < 0 && selected_node.get_index() >= %ItemList.columns) || \
		(direction > 0 && selected_node.get_index() < %ItemList.get_child_count()-%ItemList.columns):
			selected_node = %ItemList.get_child(selected_node.get_index()+(%ItemList.columns*direction))


func update_weapons() -> void:
	# add the weapon pause menu scenes if they don't exist yet
	if %WeaponList.get_child_count() == 0:
		for i in GlobalWeapons.weapon_objects:
			var menu_item = MENU_WEAPON.instantiate()
			%WeaponList.add_child(menu_item)
	# set menu node setting (see menu_weapon.tscn for the children settings)
	for i in %WeaponList.get_children():
		# get the weapon object for lookup
		var weapon_id:int = i.get_index()
		var weapon_object:Weapon = GlobalWeapons.weapon_objects[weapon_id]
		# set visibility based on if the weapon_object is available
		i.visible = weapon_object.collected
		# set node properties
		i.get_node("Name").text = weapon_object.label
		i.get_node("Icon").texture = weapon_object.icon
		i.get_node("Ammo").visible = weapon_object.max_ammo > 0
		if weapon_object.max_ammo > 0:
			i.get_node("Ammo").max_value = float(weapon_object.max_ammo)
			i.get_node("Ammo").value = (float(weapon_object.ammo)/float(weapon_object.max_ammo))*float(weapon_object.max_ammo)
		i.get_node("AmmoCount").visible = i.get_node("Ammo").visible
		i.get_node("AmmoCount").text = str(weapon_object.ammo)+"/"+str(weapon_object.max_ammo)

func update_items() -> void:
	# add the items to pause menu scenes if they don't exist yet
	if %ItemList.get_child_count() == 0:
		for i in Item.item_keys:
			var item:Item = Item.item_keys[i]
			var menu_item = MENU_ITEM.instantiate()
			%ItemList.add_child(menu_item)
			menu_item.get_node("Icon").texture = item.icon
			# set item node name ot the key (to look up data)
			menu_item.name = i
	
	for i in %ItemList.get_children():
		i.visible = Item.item_keys[i.name].collected


func _on_input_manager_left_pressed() -> void:
	select_direction(-1)

func _on_input_manager_right_pressed() -> void:
	select_direction(1)

func _on_input_manager_down_pressed() -> void:
	select_vert(1)

func _on_input_manager_up_pressed() -> void:
	select_vert(-1)

func _on_input_manager_start_pressed() -> void:
	unpause()

func _on_input_manager_jump_pressed() -> void:
	#check if empty
	if !selected_node: return
	# do action based on the section
	if selected_node.get_parent() == %WeaponList:
		GlobalWeapons.weapon_index = selected_node.get_index() as GlobalWeapons.WEAPONS
	# load up the item timeline if one is linked
	else:
		var get_item:Item = GlobalItems.get_child(selected_node.get_index())
		if get_item.inspect_timeline:
			Dialogic.start(get_item.inspect_timeline)
