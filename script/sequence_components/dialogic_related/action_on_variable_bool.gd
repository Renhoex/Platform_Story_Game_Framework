extends SequenceNode

enum ACTIONS {CANCEL_TIMELINE, CANCEL_IF_FALSE}
@export var dialogic_variable:String
@export var action:ACTIONS = ACTIONS.CANCEL_TIMELINE

# check dialogic variable
func activate() -> void:
	var dialogic_var = Global.convert_dialogic_string(dialogic_variable)
	match(action):
		ACTIONS.CANCEL_TIMELINE:
			if dialogic_var is bool:
				if dialogic_var:
					Global.current_timeline.stop()
		ACTIONS.CANCEL_IF_FALSE:
			if dialogic_var is bool:
				if !dialogic_var:
					Global.current_timeline.stop()
