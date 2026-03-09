extends Area2D

@export var damage:int = 1

func _physics_process(_delta: float) -> void:
	for i in get_overlapping_bodies():
		if i is Player:
			var dir = int(sign(i.global_position.x-global_position.x))
			# force dir if 0
			if dir == 0:
				dir = 1
			i.do_damage(damage,dir)
