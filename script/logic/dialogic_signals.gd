extends Node

@export var dialogic_variable:String

signal variable_is_true
signal variable_is_false
signal variable_int(number:int)
signal variable_float(number:float)
signal variable_string(string:String)

func _ready() -> void:
	var dialogic_var = Global.convert_dialogic_string(dialogic_variable)
	# emit signals based on if it's a bool variable
	if dialogic_var is bool:
		if dialogic_var:
			variable_is_true.emit()
		else:
			variable_is_false.emit()
	# emit signals based on if it's an int
	elif dialogic_var is int:
		variable_int.emit(dialogic_variable)
	# emit signals based on if it's a float
	elif dialogic_var is float:
		variable_float.emit(dialogic_variable)
	# emit signals based on if it's a string
	elif dialogic_var is String:
		variable_string.emit(dialogic_variable)
