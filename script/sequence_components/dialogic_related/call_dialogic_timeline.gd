extends SequenceNode

@export_file("*.dtl") var timeline:String
@export var label:String

@export var lock_timeline:bool = true

# run dialogic timeline
func activate() -> void:
	if label:
		Dialogic.start(timeline,label)
	else:
		Dialogic.start(timeline)
	
	if lock_timeline:
		Global.current_timeline.locked = true
		await Dialogic.timeline_ended
		# check that current timeline exists
		if Global.current_timeline:
			Global.current_timeline.locked = false
