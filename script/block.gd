class_name Block extends StaticBody2D

const PUFF = preload("uid://d0vbfsam5masf")

func destroy():
	hide()
	collision_layer = 0
	collision_mask = 0
	var puff = PUFF.instantiate()
	puff.global_position = global_position
	add_sibling(puff)
