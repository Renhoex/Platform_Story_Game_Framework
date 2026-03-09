extends Camera2D

@export var target_node:Node2D = null
var camera_box:Area2D = Area2D.new()
const bitmap_sides_array:PackedInt32Array = [1<<0,1<<1,1<<2,1<<3]
var shift:Vector2 = Vector2.ZERO
var skip_check_limit:bool = false

func _ready() -> void:
	add_child(camera_box)
	camera_box.collision_layer = 0
	camera_box.collision_mask = 512
	var col:CollisionShape2D = CollisionShape2D.new()
	col.shape = RectangleShape2D.new()
	camera_box.add_child(col)
	col.shape.size = Vector2(1.0,1.0)
	camera_box.area_exited.connect(force_skip_check)
	await get_tree().physics_frame # allow 2 frames to let the physics objects check for overlapping areas
	await get_tree().physics_frame
	check_limits()
	reset_smoothing()

func _physics_process(delta: float) -> void:
	# check skip_check_limit, if it's on then delay the camera snapping by a frame
	# (fixes a bug where the camera would snap out of the screen limits when unpausing after loading a dialogic timeline
	# because of how the pausing is handled)
	if skip_check_limit:
		skip_check_limit = false
	else:
		check_limits()
	if target_node:
		global_position = target_node.global_position
		if target_node is Player:
			var get_x_shift:float = target_node.input_manager.x_input
			if target_node.input_manager.y_input == 0.0:
				get_x_shift = target_node.direction
			shift = shift.move_toward(Vector2(get_x_shift,target_node.input_manager.y_input).normalized(),delta)
			position += shift*64.0
		camera_box.global_position = target_node.global_position

func force_skip_check(_area:Area2D) -> void:
	skip_check_limit = true

func check_limits() -> void:
	# reset limits if there's no overlapping areas
	limit_top = Vector2i.MIN.y
	limit_bottom = Vector2i.MAX.y
	limit_left = Vector2i.MIN.x
	limit_right = Vector2i.MAX.x

	for i in camera_box.get_overlapping_areas():
		if i.get_parent() is ReferenceRect:
			#assuming the area is using the area script, this will crash the game if an areas parent is a reference rect with no area script
			var get_area:ReferenceRect = i.get_parent()
			
			# use min and max to make sure we go for the closest point rather then the last area on the list
			# compare bit for top
			if bitmap_sides_array[0] & get_area.border_sides:
				limit_top = max(limit_top,int(get_area.global_position.y))
			# compare bit for bottom
			if bitmap_sides_array[1] & get_area.border_sides:
				limit_bottom = min(limit_bottom,int(get_area.global_position.y+get_area.size.y))
			# compare bit for left
			if bitmap_sides_array[2] & get_area.border_sides:
				limit_left = max(limit_left,int(get_area.global_position.x))
			# compare bit for right
			if bitmap_sides_array[3] & get_area.border_sides:
				limit_right = min(limit_right,int(get_area.global_position.x+get_area.size.x))
	


func snap_limits_to_camera() -> void:
	limit_left   = int(get_screen_center_position().round().x-(get_viewport_rect().size.x/2.0))
	limit_right  = int(get_screen_center_position().round().x+(get_viewport_rect().size.x/2.0))
	limit_top    = int(get_screen_center_position().round().y-(get_viewport_rect().size.y/2.0))
	limit_bottom = int(get_screen_center_position().round().y+(get_viewport_rect().size.y/2.0))
