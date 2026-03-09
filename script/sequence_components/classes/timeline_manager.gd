@icon("res://graphics/icons/DialogicCallIcon.svg")
class_name TimeLineHandler extends Node

@export var default_sequence_delay:float = 0.0

signal sequence_finished

var is_activated:bool = false
var locked:bool = false
var next_step_counter:int = 0

func _ready() -> void:
	if Global.sequence_call == name:
		# reset call
		Global.sequence_call = ""
		# activate
		activate()

func activate() -> void:
	if is_activated || Global.current_timeline: return
	# if not already running then run through the sequence
	is_activated = true
	Global.current_timeline = self
	Dialogic.signal_event.connect(_on_dialogic_signal)
	# activate any seqeunce nodes
	for i in get_children():
		if !is_activated:
			return
		
		if i is SequenceNode:
			i.parent_timeline = self
			i.activate()
		if i is Timer:
			i.start()
			await i.timeout
		if default_sequence_delay > 0.0:
			await get_tree().create_timer(default_sequence_delay).timeout
		# enter look while timelines are locked (if force next event, continue and reset the value)
		while locked && next_step_counter <= 0:
			if !is_inside_tree(): return # error prevention
			await get_tree().physics_frame
		if next_step_counter > 0:
			next_step_counter -= 1
	
	# extra check if we're at hte end of the timeline (useful if dialogic isn't finished)
	while locked:
		await get_tree().physics_frame
	
	# turn off is activated to allow the sequence to be called again
	stop()

func stop():
	if is_activated:
		is_activated = false
		Global.current_timeline = null
		emit_signal("sequence_finished")
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
		next_step_counter = 0

func _on_dialogic_signal(argument:String) -> void:
	match(argument):
		"continue_timeline":
			next_step_counter += 1
