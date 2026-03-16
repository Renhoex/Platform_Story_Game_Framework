extends CanvasLayer

var id:int = 0:
	set(value):
		%StageContainer.get_child(id).modulate = Color.DIM_GRAY
		id = value
		%StageContainer.get_child(id).modulate = Color.WHITE
		
		$Panel2/List.scroll_vertical = max(0,id-5)*12

func _ready() -> void:
	
	var dir:PackedStringArray = ResourceLoader.list_directory("res://scenes/")
	for i in dir:
		# check for sub directory, currently it only goes one folder deep
		var sub_dir:PackedStringArray = ResourceLoader.list_directory("res://scenes/"+i)
		if sub_dir:
			for j in sub_dir:
				# add additional sub string
				var label:Label = Label.new()
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.text = i+j
				label.modulate = Color.DIM_GRAY
				%StageContainer.add_child(label)
		# if there isn't any sub directory then add the current
		else:
			var label:Label = Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.text = i
			label.modulate = Color.DIM_GRAY
			%StageContainer.add_child(label)
	id = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("gm_down"):
		id = int(fmod(id+1,%StageContainer.get_child_count()))
	elif event.is_action_pressed("gm_up"):
		id = int(fposmod(id-1,%StageContainer.get_child_count()))
	elif event.is_action_pressed("gm_jump") || event.is_action_pressed("gm_start"):
		get_tree().change_scene_to_file("res://scenes/"+%StageContainer.get_child(id).text)
