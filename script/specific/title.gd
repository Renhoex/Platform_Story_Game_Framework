extends CanvasLayer

const COLOUR_OFF = Color.DIM_GRAY
const COLOUR_ON = Color.WHITE

var option:int = 0:
	set(value):
		%MenuOptions.get_child(option).modulate = COLOUR_OFF
		option = value
		%MenuOptions.get_child(option).modulate = COLOUR_ON

func _ready() -> void:
	for i in %MenuOptions.get_children():
		i.modulate = COLOUR_OFF
	option = 0
	# reset progress values
	Progress.reset()


func _on_input_manager_up_pressed() -> void:
	option = wrapi(option-1,0,%MenuOptions.get_child_count())

func _on_input_manager_down_pressed() -> void:
	option = wrapi(option+1,0,%MenuOptions.get_child_count())


func _on_input_manager_start_pressed() -> void:
	match(option):
		0: # new game
			# lock input manager to allow fading
			$InputManager.locked = true
			GlobalOverlay.fade()
			await GlobalOverlay.fade_finished
			get_tree().change_scene_to_file("res://scenes/EntryWay.tscn")
		1: # load game
			# set value to true to enable loading
			Global.call_save_menu(true)
		2: # debug
			get_tree().change_scene_to_file("res://global/debug_select.tscn")
