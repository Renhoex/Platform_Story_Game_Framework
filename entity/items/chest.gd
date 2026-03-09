extends InteractTrigger

# set variables for gaining items (see set_item_properties.gd)
@export var is_weapon:bool = false
@export var item_id:String = "[UNDEFINED]"

@onready var set_item: Node = $ChestTimeline/SetItem

func _ready() -> void:
	# sync values
	set_item.is_weapon = is_weapon
	set_item.item_id = item_id
	
	if is_weapon && Weapon.weapon_keys[item_id]:
		if Weapon.weapon_keys[item_id].collected:
			$Chest.frame = 1
	elif !is_weapon && Item.item_keys[item_id]:
		if Item.item_keys[item_id].collected:
			$Chest.frame = 1
