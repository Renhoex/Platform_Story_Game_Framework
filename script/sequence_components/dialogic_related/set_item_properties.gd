extends SequenceNode

@export var is_weapon:bool = false
# has to match a weapon name in Global Weapons (Standard, MachineGun, Wave, Rocket)
@export var item_id:String = "[UNDEFINED]"


func activate() -> void:
	Global.set_current_item(item_id,is_weapon)
