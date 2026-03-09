@tool
extends ReferenceRect

@export_flags("Top","Down","Left","Right") var border_sides:int = 15:
	set(value):
		border_sides = value
		queue_redraw()

@export var debug_show_default_size = false:
	set(value):
		debug_show_default_size = value
		queue_redraw()

var area:Area2D = Area2D.new()

func _ready() -> void:
	if Engine.is_editor_hint(): return
	# generate border area
	add_child(area)
	area.collision_layer = 512
	area.collision_mask = 0
	var col:CollisionShape2D = CollisionShape2D.new()
	area.add_child(col)
	col.shape = RectangleShape2D.new()
	col.shape.size = size
	col.debug_color = Color(0.694, 0.2, 0.816, 0.322)
	area.position = size/2.0
	

func _draw() -> void:
	# don't draw in game
	if !Engine.is_editor_hint(): return
	var rects:Array[Rect2] = [
	Rect2(size*Vector2(0.0,0.0),size*Vector2(1.0,0.0)), # top
	Rect2(size*Vector2(0.0,1.0),size*Vector2(1.0,1.0)), # bottom
	Rect2(size*Vector2(0.0,0.0),size*Vector2(0.0,1.0)), # left
	Rect2(size*Vector2(1.0,0.0),size*Vector2(1.0,1.0)), # right
	]
	# set barrier
	for i in range(4):
		# check each flag bit matchs, if you don't know what this does look up bitwise operators
		if (1<<i) & border_sides:
			draw_line(rects[i].position,rects[i].size,border_color,3.0)
	# show default screen size
	if debug_show_default_size:
		draw_rect(Rect2(Vector2.ZERO,Vector2(320.0,240.0)),Color(1.0, 1.0, 0.0, 0.373),false,2.0)
