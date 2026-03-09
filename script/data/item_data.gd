class_name Item extends Node

@export var icon = preload("res://graphics/item_icons/Key.png")
@export var collected:bool = false
@export var label:String = ""
@export_file("*.dtl") var inspect_timeline:String
static var item_keys:Dictionary[String, Item] = {}

# filled up using RESET_VALUES in ready
var default_values:Dictionary[String, Variant] = {}
# add string values for any settings you'd wanna reset on a game restart
const RESET_VALUES:PackedStringArray = [
"collected",
]

func _ready() -> void:
	# assign weapon keys to set (static value that can be accessed from the class name)
	# fastest way to do a lookup by string
	item_keys[name] = self
	# fill up the default values for resetting
	for i:String in RESET_VALUES:
		# check value is in self
		if i in self:
			default_values[i] = get(i)
		else:
			print("ERROR: value not found - "+i)

func reset_to_default() -> void:
	# loop through default values, if they exist then set the matching variables to them
	for i in default_values.keys():
		# check that value exists in default and self
		if i in self && default_values.has(i):
			set(i,default_values[i])
		else:
			print("ERROR: value not found - "+i)
