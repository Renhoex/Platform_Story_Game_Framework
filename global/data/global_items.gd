extends Node

func unlock_item(item_id:String = ""):
	if has_node(item_id):
		get_node(item_id).collected = true
		if Dialogic.VAR.ITEMS.item_id == item_id:
			Dialogic.VAR.ITEMS.collected = true

func remove_item(item_id:String = ""):
	if has_node(item_id):
		get_node(item_id).collected = false
		if Dialogic.VAR.ITEMS.item_id == item_id:
			Dialogic.VAR.ITEMS.collected = false
