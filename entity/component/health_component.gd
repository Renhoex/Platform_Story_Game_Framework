class_name HealthComponent extends Node

@export var max_health:int = 30
@export var health: int = 30:
	set(value):
		health = clamp(value,0,max_health)
		if health <= 0:
			dead.emit()

signal dead
