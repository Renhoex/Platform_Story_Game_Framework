@icon("res://graphics/icons/StateIcon.svg")
class_name PlayerState extends Node

@onready var player:Player = get_parent().get_parent()
@export var  can_fire:bool = false

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta:float) -> void:
	pass

func physics(_delta:float) -> void:
	pass
