class_name InteractTrigger extends Area2D

@export_category("Time line")
@export var timeline_target:TimeLineHandler

@export var unlock_after_sequence:bool = false

@export var skip_on_dialogic_variable:String

@export_category("Player Interaction")
@export var activate_on_touch:bool = false
@export var one_time:bool = false
var was_triggered:bool = false
@export var reset_velocity:bool = true

signal interacted(interactor)

func interact_called(interactor:Node) -> void:
	interacted.emit(interactor)
