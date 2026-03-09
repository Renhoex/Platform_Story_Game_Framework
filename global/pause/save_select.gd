extends CanvasLayer

const SAVE_FILE = preload("uid://c5hiccm1k77xi")
var loading:bool = false
static var panel_id:int = 0
@onready var highlight: Panel = $Highlight
var scroll_float:float = 0.0
var save_lock:bool = false
var can_cancel:bool = true # disables closing the save menu (useful in preventing closing it after a game over and soft locking the player)

func _ready() -> void:
	$Highlight/SaveNotifier.hide()
	get_tree().paused = true
	for i in range(Progress.SAVE_FILE_COUNT):
		var save_file = SAVE_FILE.instantiate()
		save_file.save_file_id = i
		%SaveSlots.add_child(save_file)
	#room.text = get_tree().current_scene.name.capitalize()

func _process(delta: float) -> void:
	var focussed_save:Control = %SaveSlots.get_child(panel_id)
	highlight.size = focussed_save.size
	highlight.global_position = focussed_save.global_position
	scroll_float = lerp(scroll_float,focussed_save.position.y,min(delta*5.0,1.0))
	$Panel/ScrollContainer.scroll_vertical = int(scroll_float)-96


func change_file(direction:int = 1) -> void:
	if save_lock: return
	panel_id = wrapi(panel_id+direction,0,Progress.SAVE_FILE_COUNT)

func _on_input_manager_up_pressed() -> void:
	change_file(-1)

func _on_input_manager_down_pressed() -> void:
	change_file(1)

func _confirm_pressed() -> void:
	# set file id
	Progress.save_file_id = panel_id
	if loading:
		if Progress.load_game(): # let progress handle the loading
			# unload self and delete
			get_tree().paused = false
			queue_free()
		else: # else play an error sound and don't do anything
			# play error sound
			$Error.play()
		return # cut off rest of script
	if save_lock: return
	save_lock = true
	$Highlight/SaveNotifier.show()
	# play save sound
	$Save.play()
	# save the game
	Progress.save_data()
	# update the currently selected file
	%SaveSlots.get_child(panel_id).read_file()
	# wait a sec to let the player know the game saved
	await get_tree().create_timer(0.75).timeout
	get_tree().paused = false
	queue_free()


func _cancel_pressed() -> void:
	if save_lock || !can_cancel: return
	get_tree().paused = false
	queue_free()
